import 'dart:convert';

import 'package:ceremony/bottom_nav.dart';
import 'package:ceremony/models/guest.dart';
import 'package:ceremony/models/ticket.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class Attendeedetails extends StatefulWidget {
  const Attendeedetails({super.key});

  @override
  State<Attendeedetails> createState() => _AttendeedetailsState();
}

class _AttendeedetailsState extends State<Attendeedetails> {
  bool loading = true;
  String type = '';
  List<Guest> guestList = [];
  List<String> guestCheckInList = [];
  List<String> guestCheckOutList = [];

  final String url = "https://issatsoceremony.netlify.app";

  Future<bool> confirmCheckIn(
      String personId, String ticketId, bool checkIn) async {
    String uri = '';
    if (type == 'Spectator') {
      uri = '$url/api/checkin/spectators/$personId';
    } else {
      uri = '$url/api/checkin/tickets/$ticketId';
    }
    final Map<String, dynamic> body = {
      'guestIds': guestCheckInList,
    };

    if (checkIn) {
      body['attendeeId'] = personId;
    }
    final response = await http.post(
      Uri.parse(uri),
      headers: {'Content-Type': 'application/json', 'x-api-key': 'nateg-2025'},
      body: jsonEncode(body),
    );
    return (response.statusCode == 200);
  }

  Future<bool> confirmCheckOut(
      String personId, String ticketId, bool checkIn) async {
    String uri = '';
    if (type == 'Spectator') {
      uri = '$url/api/checkin/spectators/$personId';
    } else {
      uri = '$url/api/checkin/tickets/$ticketId';
    }
    final Map<String, dynamic> body = {
      'guestIds': guestCheckOutList,
    };

    if (!checkIn) {
      body['attendeeId'] = personId;
    }
    final response = await http.delete(
      Uri.parse(uri),
      headers: {'Content-Type': 'application/json', 'x-api-key': 'nateg-2025'},
      body: jsonEncode(body),
    );
    return (response.statusCode == 200);
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      throw 'Could not launch $launchUri';
    }
  }

  bool currentStatus = false;
  bool firstRun = false;
  @override
  Widget build(BuildContext context) {
    var ticket = ModalRoute.of(context)!.settings.arguments as Ticket;
    dynamic person;
    if (ticket.attendee != null) {
      person = ticket.attendee!;
      type = 'Attendee';
    } else if (ticket.spectator != null) {
      person = ticket.spectator!;
      type = 'Spectator';
    }
    if (!firstRun) {
      currentStatus = person.checkIn;
    }
    setState(() {
      loading = false;
      guestList = ticket.guests;
      firstRun = true;
    });
    return PopScope(
      canPop: false,
      child: Scaffold(
        bottomNavigationBar: CustomBottomNav(activeIndex: 5),
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        appBar: AppBar(
          backgroundColor: const Color.fromARGB(255, 255, 255, 255),
          elevation: 0,
          centerTitle: true,
          title: const Text('Attendee Details',
              style:
                  TextStyle(color: Colors.black, fontWeight: FontWeight.w600)),
          iconTheme: const IconThemeData(color: Colors.black),
          automaticallyImplyLeading: false,
          /*leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              // Manual navigation via code STILL WORKS even if canPop is false
              Navigator.of(context).pop();
            },
          ),*/
        ),
        body: SafeArea(
          child: loading
              ? Center(
                  child: CircularProgressIndicator(),
                )
              : SingleChildScrollView(
                  child: Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                    child: Column(
                      children: [
                        Text(
                          person.fullName,
                          style: TextStyle(
                              fontSize: 32.sp, fontWeight: FontWeight.w800),
                        ),
                        SizedBox(height: 20.h),

                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 30.w, vertical: 20.h),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: const Color.fromARGB(130, 158, 158, 158),
                                spreadRadius: 1,
                                blurRadius: 5,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text('Status',
                                          style: TextStyle(fontSize: 16.sp)),
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 12.w, vertical: 4.h),
                                        decoration: BoxDecoration(
                                          color: person.checkIn == false
                                              ? Colors.orange.shade100
                                              : Colors.green.shade100,
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        child: Text(
                                          person.checkIn
                                              ? 'Checked In'
                                              : 'Not Yet',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: !person.checkIn
                                                ? Colors.orange.shade800
                                                : Colors.green.shade800,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Checkbox(
                                      value: person.checkIn,
                                      onChanged: ((bool? newValue) {
                                        setState(() {
                                          person.checkIn = newValue;
                                        });
                                      }))
                                ],
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: 10.h),

                        ticket.guests.isEmpty
                            ? Text('')
                            : Column(
                                children: [
                                  SizedBox(height: 20.h),
                                  _buildSectionHeader(Icons.people, 'Guests'),
                                  SizedBox(height: 10.h),
                                  Container(
                                    //padding: EdgeInsets.symmetric(horizontal: 10),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color.fromARGB(
                                              130, 158, 158, 158),
                                          spreadRadius: 1,
                                          blurRadius: 5,
                                          offset: const Offset(0, 3),
                                        ),
                                      ],
                                    ),
                                    child: ListView.separated(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 10.w, vertical: 0),
                                      shrinkWrap: true,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      itemCount: ticket.guests.length,
                                      separatorBuilder: (context, index) =>
                                          const Divider(height: 1),
                                      itemBuilder: (context, index) {
                                        return SizedBox(
                                          height: 70.h,
                                          child: ListTile(
                                              title: Text(
                                                  guestList[index].fullName),
                                              subtitle: Text(
                                                  guestList[index].checkIn
                                                      ? 'Checked In'
                                                      : 'Not Yet'),
                                              trailing: Checkbox(
                                                  value:
                                                      guestList[index].checkIn,
                                                  onChanged: (bool? newValue) {
                                                    if (newValue!) {
                                                      guestCheckInList.add(
                                                          guestList[index].id);
                                                      guestCheckOutList.remove(
                                                          guestList[index].id);
                                                    } else {
                                                      guestCheckInList.remove(
                                                          guestList[index].id);
                                                      guestCheckOutList.add(
                                                          guestList[index].id);
                                                    }
                                                    setState(() {
                                                      guestList[index].checkIn =
                                                          newValue;
                                                    });
                                                  })),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                        SizedBox(
                          height: 20.h,
                        ),
                        // --- Ticket Details Section ---
                        _buildSectionHeader(
                            Icons.airplane_ticket, 'Ticket Details'),
                        SizedBox(height: 10.h),
                        Container(
                          padding: const EdgeInsets.all(15),
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: const Color.fromARGB(130, 158, 158, 158),
                                spreadRadius: 1,
                                blurRadius: 4,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _DetailRow(label: 'Type', value: type),
                              //if (ticket.guests.isNotEmpty)
                              Divider(height: 30.h),
                              //if (ticket.guests.isNotEmpty)
                              /*_DetailRow(
                                    label: 'Number of guests',
                                    value: ticket.guests.length.toString()),
                              Divider(height: 30),*/
                              _DetailRow(
                                label: 'Phone number',
                                value: person.phone,
                                trailing: Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: const Color(0xFF2474FF),
                                  ),
                                  child: IconButton(
                                    color: Colors.white,
                                    onPressed: () {
                                      _makePhoneCall(person.phone);
                                    },
                                    icon: Icon(
                                      Icons.phone,
                                      size: 25,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: 20.h),
                        SizedBox(
                          height: 50.h,
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2474FF),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                            onPressed: () async {
                              bool res = true;
                              if ((person.checkIn &&
                                      person.checkIn != currentStatus) ||
                                  guestCheckInList.isNotEmpty) {
                                res = await confirmCheckIn(
                                    person.id, ticket.id, person.checkIn);
                              }
                              if ((!person.checkIn &&
                                      person.checkIn != currentStatus) ||
                                  guestCheckOutList.isNotEmpty) {
                                res = await confirmCheckOut(
                                    person.id, ticket.id, person.checkIn);
                              }
                              if (res) {
                                Navigator.pushReplacementNamed(
                                    context, '/home');
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text(
                                          'An error occured, please try again.')),
                                );
                              }
                            },
                            child: Text(
                              'Confirm',
                              style: TextStyle(
                                  color: Colors.white, fontSize: 17.sp),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, size: 22, color: Colors.black87),
        SizedBox(width: 10.w),
        Text(title,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.sp)),
      ],
    );
  }
}

// Helper widget for clean code
class _DetailRow extends StatelessWidget {
  final String label, value;
  final Widget? trailing;
  const _DetailRow({required this.label, required this.value, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(color: Colors.grey, fontSize: 14.sp)),
            SizedBox(height: 4.h),
            Text(value,
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w500)),
          ],
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}
