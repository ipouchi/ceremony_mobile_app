import 'dart:convert';
import 'package:ceremony/models/participant.dart';
import 'package:ceremony/models/team.dart';
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
  List<Team> filteredTeams = [];

  int total = 100;
  List<Participant> participants = [];
  List<Team> teams = [];
  bool loading = true;

  final String url = "http://192.168.1.130:3000";

  Future<void> getTeams() async {
    final response = await http.get(Uri.parse('$url/api/teams'), headers: {
      'Content-Type': 'application/json',
    });
    if (response.statusCode == 200) {
      print(response.body);

      final List<dynamic> rawJson = jsonDecode(response.body);
      teams.clear();
      for (dynamic i in rawJson) {
        teams.add(Team.fromJson(i));
      }
      print('teams: $teams');

      // Sort alphabetically (A-Z)
      teams
          .sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
      setState(() {
        loading = false;
        filteredTeams = List.from(teams);
        total = filteredTeams.length;
      });
    }
  }

  void _filterList(String query) {
    setState(() {
      filteredTeams = teams.where((team) {
        final name = team.name.toLowerCase();
        final input = query.toLowerCase();

        // Search condition
        final matchesSearch = name.contains(input);

        // Category filter condition
        bool matchesCategory = true;
        if (selectedFilter == 'Checked In') {
          matchesCategory = team.numberOfCheckedIn == team.expectedSize;
        } else if (selectedFilter == 'Not Yet') {
          matchesCategory = team.numberOfCheckedIn != team.expectedSize;
        }

        return matchesSearch && matchesCategory;
      }).toList();

      total = filteredTeams.length;
    });
  }

  @override
  void initState() {
    super.initState();
    getTeams();
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
                            Text("Showing $total teams"),
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
                                    final matchingTeam = teams.firstWhere(
                                      (t) => t.id == filteredTeams[index].id,
                                      orElse: () =>
                                          teams[0], // Fallback if not found
                                    );
                                    final result =
                                        await Navigator.pushReplacementNamed(
                                            context, '/attendeeDetails',
                                            arguments: matchingTeam);
                                    if (result == true) {
                                      setState(() {
                                        loading = true;
                                      });
                                      getTeams();
                                    }
                                  },
                                  child: Card(
                                    elevation: 5,
                                    child: ListTile(
                                      title: Text(filteredTeams[index].name,
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18.sp)),
                                      subtitle: Builder(
                                        builder: (context) {
                                          // 1. Find the ticket that matches the current filtered attendee
                                          final currentTeam =
                                              filteredTeams[index];
                                          final matchedTeam = teams.firstWhere(
                                            (t) => t.id == currentTeam.id,
                                            orElse: () => teams[0], // Fallback
                                          );

                                          // 2. Display the correct number of guests from THAT ticket
                                          return Text(
                                            'Members: ${matchedTeam.participants?.where((g) => g.checkedIn).length ?? 0}/${matchedTeam.participants?.length ?? 0}',
                                            style: TextStyle(fontSize: 14.sp),
                                          );
                                        },
                                      ),
                                      trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          filteredTeams[index]
                                                      .numberOfCheckedIn ==
                                                  filteredTeams[index]
                                                      .expectedSize
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
