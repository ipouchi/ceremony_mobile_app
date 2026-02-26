import 'dart:convert';
import 'package:ceremony/models/attendee.dart';
import 'package:ceremony/models/spectator.dart';
import 'package:ceremony/models/ticket.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:ceremony/bottom_nav.dart';
import 'package:flutter/material.dart';

class AttendeesPage extends StatefulWidget {
  const AttendeesPage({super.key});

  @override
  State<AttendeesPage> createState() => _AttendeesPageState();
}

class _AttendeesPageState extends State<AttendeesPage> {
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> filteredAttendees = [];

  int total = 100;
  List<Attendee> attendees = [];
  List<Spectator> spectators = [];
  List<Ticket> tickets = [];
  List<dynamic> allAttendees = [];
  bool loading = true;

  final String url = "https://issatsoceremony.netlify.app";

  Future<void> getAttendees() async {
    final response = await http.get(Uri.parse('$url/api/tickets'), headers: {
      'Content-Type': 'application/json',
      'x-api-key': 'nateg-2025'
    });
    if (response.statusCode == 200) {
      final Map<String, dynamic> rawJson = jsonDecode(response.body);
      final List<dynamic> data = rawJson['data'];
      tickets.clear();
      allAttendees.clear();
      for (dynamic i in data) {
        tickets.add(Ticket.fromJson(i));
      }
      for (var ticket in tickets) {
        ticket.attendee != null
            ? allAttendees.add(ticket.attendee!)
            : allAttendees.add(ticket.spectator!);
      }
      // Sort alphabetically (A-Z)
      allAttendees.sort((a, b) =>
          a.fullName.toLowerCase().compareTo(b.fullName.toLowerCase()));
      setState(() {
        loading = false;
        filteredAttendees = List.from(allAttendees);
        total = filteredAttendees.length;
      });
    }
  }

  void _filterList(String query) {
    setState(() {
      filteredAttendees = allAttendees.where((attendee) {
        final name = attendee.fullName.toLowerCase();
        final input = query.toLowerCase();

        // Search condition
        final matchesSearch = name.contains(input);

        // Category filter condition
        bool matchesCategory = true;
        if (selectedFilter == 'Checked In') {
          matchesCategory = attendee.checkIn == true;
        } else if (selectedFilter == 'Not Yet') {
          matchesCategory = attendee.checkIn == false;
        }

        return matchesSearch && matchesCategory;
      }).toList();

      total = filteredAttendees.length; // Update the count label
    });
  }

  @override
  void initState() {
    super.initState();
    getAttendees();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      child: Scaffold(
          backgroundColor: const Color.fromARGB(255, 255, 255, 255),
          appBar: AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: const Color.fromARGB(255, 255, 255, 255),
            //backgroundColor: const Color.fromARGB(255, 211, 238, 253),
            title: Center(
              child: Text(
                "Attendees",
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ),
          body: Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w),
            //color: Colors.white,
            //color: const Color.fromARGB(255, 211, 238, 253),
            width: double.infinity,
            height: double.infinity,
            child: loading
                ? Center(
                    child: CircularProgressIndicator(
                      color: Color.fromARGB(255, 36, 116, 255),
                    ),
                  )
                : Column(
                    children: [
                      SizedBox(
                        height: 15.h,
                      ),
                      Container(
                        color: Colors.white,
                        width: 340.w,
                        child: TextField(
                          controller: _searchController,
                          onChanged: _filterList,
                          decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              //labelText: 'Enter ticket number',
                              label: Row(
                                children: [
                                  Icon(Icons.search),
                                  Text('Search by name'),
                                ],
                              )),
                        ),
                      ),
                      SizedBox(
                        height: 15.h,
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Row(
                          children: [
                            SizedBox(
                              width: 10.w,
                            ),
                            Text("Showing $total attendees"),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 10.h,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children:
                            filters.map((f) => _buildFilterButton(f)).toList(),
                      ),
                      SizedBox(
                        height: 15.h,
                      ),
                      Expanded(
                        child: ListView.builder(
                          itemCount: total,
                          itemBuilder: (context, index) {
                            return Container(
                              padding: EdgeInsets.only(
                                  left: 0, right: 0, top: 5.h, bottom: 5.h),
                              width: 350.w,
                              height: 120.h,
                              child: GestureDetector(
                                  onTap: () async {
                                    final matchingTicket = tickets.firstWhere(
                                      (t) =>
                                          t.id ==
                                          filteredAttendees[index].ticketId,
                                      orElse: () =>
                                          tickets[0], // Fallback if not found
                                    );
                                    final result =
                                        await Navigator.pushReplacementNamed(
                                            context, '/attendeeDetails',
                                            arguments: matchingTicket);
                                    if (result == true) {
                                      setState(() {
                                        loading = true;
                                      });
                                      getAttendees();
                                    }
                                  },
                                  child: Card(
                                    elevation: 5,
                                    child: ListTile(
                                      title: Text(
                                          filteredAttendees[index].fullName,
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18.sp)),
                                      subtitle: Builder(
                                        builder: (context) {
                                          // 1. Find the ticket that matches the current filtered attendee
                                          final currentAttendee =
                                              filteredAttendees[index];
                                          final matchingTicket =
                                              tickets.firstWhere(
                                            (t) =>
                                                t.id ==
                                                currentAttendee.ticketId,
                                            orElse: () =>
                                                tickets[0], // Fallback
                                          );

                                          // 2. Display the correct number of guests from THAT ticket
                                          return Text(
                                            '${currentAttendee is Attendee ? "Graduated" : 'Spectator'}\nGuests: ${matchingTicket.guests.where((g) => g.checkIn).length}/${matchingTicket.guests.length}',
                                            style: TextStyle(fontSize: 14.sp),
                                          );
                                        },
                                      ),
                                      trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          filteredAttendees[index].checkIn
                                              ? Icon(Icons.check_circle_outline,
                                                  color: Colors.green)
                                              : Icon(
                                                  Icons.access_time,
                                                  color: Colors.red,
                                                ),
                                          Icon(Icons.keyboard_arrow_right),
                                        ],
                                      ),
                                    ),
                                  )),
                            );
                          },
                        ),
                      )
                    ],
                  ),
          ),
          bottomNavigationBar: CustomBottomNav(
            activeIndex: 2,
          )),
    );
  }

  String selectedFilter = 'All';
  final List<String> filters = ['All', 'Checked In', 'Not Yet'];

  Widget _buildFilterButton(String label) {
    bool isSelected = selectedFilter == label;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedFilter = label;
        });
        _filterList(_searchController.text);
      },
      child: Container(
        margin: const EdgeInsets.only(right: 0, left: 5),
        padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 10.h),
        decoration: BoxDecoration(
          // Apply Gradient only to the selected "All" or active button
          gradient: isSelected
              ? const LinearGradient(
                  colors: [Color(0xFF6366f1), Color(0xFFa855f7)])
              : null,
          color: isSelected ? null : Colors.white,
          borderRadius: BorderRadius.circular(25),
          border: isSelected ? null : Border.all(color: Colors.grey.shade300),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                      color: const Color.fromARGB(88, 155, 39, 176),
                      blurRadius: 8,
                      offset: const Offset(0, 4))
                ]
              : [],
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey.shade700,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
