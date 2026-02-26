import 'dart:convert';

import 'package:ceremony/bottom_nav.dart';
import 'package:ceremony/models/attendee.dart';
import 'package:ceremony/models/ticket.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int total = 100;
  int pending = 30;
  int checkedIn = 60;
  int absent = 10;

  bool loading = true;

  final String url = "https://issatsoceremony.netlify.app";

  Future<void> getStats() async {
    final response = await http.get(Uri.parse('$url/api/checkin/stats'),
        headers: {
          'Content-Type': 'application/json',
          'x-api-key': 'nateg-2025'
        });
    if (response.statusCode == 200) {
      final Map<String, dynamic> rawJson = jsonDecode(response.body);
      final data = rawJson['data'];
      setState(() {
        total = data["totalPeople"]!;
        checkedIn = data["totalCheckedIn"]!;
        pending = total - checkedIn;
        loading = false;
      });
    }
  }

  List<Ticket> tickets = [];
  List<dynamic> allAttendees = [];

  Future<void> getRecentCheckIns() async {
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

      List<dynamic> checkedInPeople = [];
      for (var ticket in tickets) {
        dynamic person = ticket.attendee ?? ticket.spectator;
        if (person != null && person.checkIn == true) {
          checkedInPeople.add(person);
        }
      }
      checkedInPeople.sort((a, b) {
        DateTime dateA = DateTime.parse(a.updatedAt);
        DateTime dateB = DateTime.parse(b.updatedAt);
        return dateB.compareTo(dateA);
      });

      setState(() {
        loading = false;
        allAttendees = checkedInPeople.take(3).toList();
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getStats();
    getRecentCheckIns();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
          backgroundColor: const Color.fromARGB(255, 255, 255, 255),
          appBar: AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: Colors.white,
            //backgroundColor: const Color.fromARGB(255, 211, 238, 253),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "January 24, 2026",
                  style: TextStyle(
                      fontSize: 13.sp,
                      color: const Color.fromARGB(255, 94, 94, 94)),
                ),
                Text(
                  'Graduation 2025',
                  style: GoogleFonts.robotoSlab(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          body: loading
              ? Center(
                  child: CircularProgressIndicator(
                    color: Color.fromARGB(255, 36, 116, 255),
                  ),
                )
              : SizedBox(
                  width: double.infinity,
                  height: double.infinity,
                  child: Column(
                    children: [
                      SizedBox(
                        height: 5.h,
                      ),
                      Container(
                        width: 360.w,
                        padding: EdgeInsets.all(17.sp),
                        margin: EdgeInsets.symmetric(
                            horizontal: 15.w, vertical: 5.h),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: const Color.fromARGB(130, 158, 158, 158),
                              spreadRadius: 2,
                              blurRadius: 5,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Attendance:',
                              style: TextStyle(fontSize: 17.sp),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      checkedIn.toString(),
                                      style: TextStyle(
                                          fontSize: 30.sp,
                                          fontWeight: FontWeight.w800),
                                    ),
                                    Text(
                                      '/$total',
                                      style: TextStyle(
                                          fontSize: 17.sp, color: Colors.grey),
                                    ),
                                  ],
                                ),
                                Text(
                                  '${total == 0 ? 0 : (checkedIn / total * 100).round()}%',
                                  style: TextStyle(
                                      fontSize: 17.sp, color: Colors.blue),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 10.h,
                            ),
                            LinearProgressIndicator(
                              value: total == 0 ? 0 : checkedIn / total,
                              color: Colors.blue,
                              minHeight: 10.h,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            SizedBox(
                              height: 5.h,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 10.h,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Container(
                            padding: EdgeInsets.all(17.sp),
                            margin: EdgeInsets.symmetric(
                                horizontal: 10.w, vertical: 5.h),
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(255, 250, 248, 255),
                              borderRadius: BorderRadius.circular(15),
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      const Color.fromARGB(130, 158, 158, 158),
                                  spreadRadius: 2,
                                  blurRadius: 5,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            width: 165.w,
                            //color: Colors.green,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.check_circle_outline_outlined,
                                      size: 25,
                                      color: Colors.green,
                                    ),
                                    SizedBox(
                                      width: 5.w,
                                    ),
                                    Text(
                                      'Checked in',
                                      style: TextStyle(fontSize: 16.sp),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 10.h,
                                ),
                                Text(
                                  checkedIn.toString(),
                                  style: TextStyle(
                                      fontSize: 30.sp,
                                      fontWeight: FontWeight.w800),
                                )
                              ],
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.all(17.sp),
                            margin: EdgeInsets.symmetric(
                                horizontal: 10.w, vertical: 5.h),
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(255, 255, 241, 241),
                              borderRadius: BorderRadius.circular(15),
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      const Color.fromARGB(130, 158, 158, 158),
                                  spreadRadius: 2,
                                  blurRadius: 5,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            width: 165.w,
                            //color: Colors.red,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.access_time,
                                      size: 25,
                                      color: Colors.red,
                                    ),
                                    SizedBox(
                                      width: 5.w,
                                    ),
                                    Text(
                                      'Not Yet',
                                      style: TextStyle(fontSize: 16.sp),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 10.h,
                                ),
                                Text(
                                  pending.toString(),
                                  style: TextStyle(
                                      fontSize: 30.sp,
                                      fontWeight: FontWeight.w800),
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 10.h,
                      ),
                      SizedBox(
                        width: 350.w,
                        height: 60.h,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color.fromARGB(255, 36, 116, 255),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15.0)),
                          ),
                          onPressed: () {
                            Navigator.pushReplacementNamed(context, '/scan');
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.qr_code_scanner,
                                color: Colors.white,
                                size: 25,
                              ),
                              SizedBox(
                                width: 5.w,
                              ),
                              Text(
                                'Add ticket',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 17.sp),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 15.h,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Text(
                            'Recent Check-ins',
                            style: TextStyle(
                                fontSize: 17.sp, fontWeight: FontWeight.w600),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pushReplacementNamed(
                                  context, '/attendees');
                            },
                            child: Text(
                              'View All',
                              style: TextStyle(
                                  color:
                                      const Color.fromARGB(255, 36, 116, 255)),
                            ),
                          )
                        ],
                      ),
                      Container(
                        width: double.infinity,
                        height: 245.h,
                        //color: Colors.white,
                        margin: EdgeInsets.symmetric(horizontal: 15.w),
                        padding: EdgeInsets.symmetric(horizontal: 10.w),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: const Color.fromARGB(130, 158, 158, 158),
                              spreadRadius: 2,
                              blurRadius: 5,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: allAttendees.isEmpty
                            ? Center(
                                child: Text(
                                  'No check in yet',
                                  style: TextStyle(fontSize: 20.sp),
                                ),
                              )
                            : ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: allAttendees.length,
                                separatorBuilder: (context, index) =>
                                    const Divider(height: 1),
                                itemBuilder: (context, index) {
                                  dynamic person = allAttendees[index];
                                  DateTime updateTime =
                                      DateTime.parse(person.updatedAt);
                                  return ListTile(
                                    title: Text(person.fullName),
                                    subtitle: Text(person is Attendee
                                        ? 'Graduate'
                                        : 'Spectator'),
                                    trailing: Text(
                                        '${updateTime.hour}:${updateTime.minute}'),
                                    onTap: () {
                                      final matchingTicket = tickets.firstWhere(
                                        (t) =>
                                            t.id ==
                                            allAttendees[index].ticketId,
                                      );
                                      Navigator.pushReplacementNamed(
                                          context, '/attendeeDetails',
                                          arguments: matchingTicket);
                                    },
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                ),
          bottomNavigationBar: CustomBottomNav(
            activeIndex: 0,
          )),
    );
  }
}
