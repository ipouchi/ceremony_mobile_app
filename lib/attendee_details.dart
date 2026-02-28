import 'dart:convert';

import 'package:ceremony/bottom_nav.dart';
import 'package:ceremony/models/participant.dart';
import 'package:ceremony/models/team.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;

class Attendeedetails extends StatefulWidget {
  const Attendeedetails({super.key});

  @override
  State<Attendeedetails> createState() => _AttendeedetailsState();
}

class _AttendeedetailsState extends State<Attendeedetails> {
  bool loading = true;
  List<Participant> participantList = [];
  List<int> guestCheckInList = [];
  List<int> guestCheckOutList = [];

  final String url = "http://192.168.1.130";

  Future<bool> confirmCheckIn(int teamId) async {
    final uri = '$url/api/checkin/tickets/$teamId';
    final Map<String, dynamic> body = {
      'guestIds': guestCheckInList,
    };
    final response = await http.post(
      Uri.parse(uri),
      headers: {'Content-Type': 'application/json', 'x-api-key': 'nateg-2025'},
      body: jsonEncode(body),
    );
    return (response.statusCode == 200);
  }

  Future<bool> confirmCheckOut(int teamId) async {
    final uri = '$url/api/checkin/tickets/$teamId';
    final Map<String, dynamic> body = {
      'guestIds': guestCheckOutList,
    };
    final response = await http.delete(
      Uri.parse(uri),
      headers: {'Content-Type': 'application/json', 'x-api-key': 'nateg-2025'},
      body: jsonEncode(body),
    );
    return (response.statusCode == 200);
  }

  bool firstRun = false;
  @override
  Widget build(BuildContext context) {
    var team = ModalRoute.of(context)!.settings.arguments as Team;

    if (!firstRun) {
      setState(() {
        loading = false;
        participantList = team.participants ?? [];
        firstRun = true;
      });
    }
    return PopScope(
      canPop: false,
      child: Scaffold(
        bottomNavigationBar: CustomBottomNav(activeIndex: 5),
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        appBar: AppBar(
          backgroundColor: const Color.fromARGB(255, 255, 255, 255),
          elevation: 0,
          centerTitle: true,
          title: const Text('Team Details',
              style:
                  TextStyle(color: Colors.black, fontWeight: FontWeight.w600)),
          iconTheme: const IconThemeData(color: Colors.black),
          automaticallyImplyLeading: false,
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
                          team.name,
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
                                          color: team.numberOfCheckedIn ==
                                                  team.expectedSize
                                              ? Colors.green.shade100
                                              : Colors.orange.shade100,
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        child: Text(
                                          team.numberOfCheckedIn ==
                                                  team.expectedSize
                                              ? 'Checked In'
                                              : 'Not Yet',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: team.numberOfCheckedIn ==
                                                    team.expectedSize
                                                ? Colors.green.shade800
                                                : Colors.orange.shade800,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Checkbox(
                                      value: team.numberOfCheckedIn ==
                                          team.expectedSize,
                                      onChanged: ((bool? newValue) {
                                        setState(() {
                                          if (newValue!) {
                                            for (var p in team.participants!) {
                                              if (!p.checkedIn) {
                                                p.checkedIn = true;
                                                guestCheckInList.add(p.id);
                                                guestCheckOutList.remove(p.id);
                                              }
                                            }
                                            team.numberOfCheckedIn =
                                                team.expectedSize;
                                          } else {
                                            for (var p in team.participants!) {
                                              if (p.checkedIn) {
                                                p.checkedIn = false;
                                                guestCheckOutList.add(p.id);
                                                guestCheckInList.remove(p.id);
                                              }
                                            }
                                            team.numberOfCheckedIn = 0;
                                          }
                                        });
                                      }))
                                ],
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 10.h),
                        team.participants!.isEmpty
                            ? Text('')
                            : Column(
                                children: [
                                  SizedBox(height: 20.h),
                                  _buildSectionHeader(Icons.people, 'Guests'),
                                  SizedBox(height: 10.h),
                                  Container(
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
                                      itemCount: team.participants!.length,
                                      separatorBuilder: (context, index) =>
                                          const Divider(height: 1),
                                      itemBuilder: (context, index) {
                                        return SizedBox(
                                          height: 70.h,
                                          child: ListTile(
                                              title: Text(team
                                                  .participants![index]
                                                  .fullName),
                                              subtitle: Text(team
                                                      .participants![index]
                                                      .checkedIn
                                                  ? 'Checked In'
                                                  : 'Not Yet'),
                                              trailing: Checkbox(
                                                  value: team
                                                      .participants![index]
                                                      .checkedIn,
                                                  onChanged: (bool? newValue) {
                                                    if (newValue!) {
                                                      guestCheckInList.add(team
                                                          .participants![index]
                                                          .id);
                                                      guestCheckOutList.remove(
                                                          team
                                                              .participants![
                                                                  index]
                                                              .id);
                                                      team.numberOfCheckedIn++;
                                                    } else {
                                                      guestCheckInList.remove(
                                                          team
                                                              .participants![
                                                                  index]
                                                              .id);
                                                      guestCheckOutList.add(team
                                                          .participants![index]
                                                          .id);
                                                      team.numberOfCheckedIn--;
                                                    }
                                                    print(
                                                        team.numberOfCheckedIn);
                                                    setState(() {
                                                      team.participants![index]
                                                          .checkedIn = newValue;
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
                              if (guestCheckInList.isNotEmpty) {
                                res = await confirmCheckIn(team.id);
                              }
                              if (res && guestCheckOutList.isNotEmpty) {
                                res = await confirmCheckOut(team.id);
                              }
                              if (res) {
                                Navigator.pushReplacementNamed(
                                    context, '/home');
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text(
                                          'An error occurred, please try again.')),
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
