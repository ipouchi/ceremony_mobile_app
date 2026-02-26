import 'package:ceremony/attendee_details.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'attendees.dart';
import 'home.dart';
import 'scan.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
        designSize: const Size(412, 915),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            routes: {
              "/home": (BuildContext context) => const HomePage(),
              "/scan": (BuildContext context) => const ScanPage(),
              "/attendees": (BuildContext context) => const AttendeesPage(),
              "/attendeeDetails": (BuildContext context) =>
                  const Attendeedetails(),
            },
            title: 'Flutter Demo',
            theme: ThemeData(
                colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
                useMaterial3: true,
                textTheme: GoogleFonts.lexendTextTheme(
                  Theme.of(context).textTheme,
                )),
            home: child,
          );
        },
        child: const HomePage());
  }
}
