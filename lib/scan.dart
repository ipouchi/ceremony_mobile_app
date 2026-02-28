import 'dart:convert';

import 'package:ceremony/bottom_nav.dart';
import 'package:ceremony/models/ticket.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'package:collection/collection.dart';

class ScanPage extends StatefulWidget {
  const ScanPage({super.key});

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> with WidgetsBindingObserver {
  void checkPermission() async {
    var status = await Permission.camera.status;

    if (status.isDenied) {
      // Request for the first time
      await Permission.camera.request();
    } else if (status.isPermanentlyDenied) {
      // User clicked 'Don't ask again' - take them to settings
      openAppSettings();
    }
  }

  final MobileScannerController scannerController = MobileScannerController(
      autoStart: false, detectionSpeed: DetectionSpeed.noDuplicates);

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    scannerController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached ||
        state == AppLifecycleState.hidden) {
      scannerController.stop();
    } else if (state == AppLifecycleState.resumed) {
      scannerController.start();
    }
  }

  @override
  void deactivate() {
    scannerController.stop();
    super.deactivate();
  }

  final String url = "https://issatsoceremony.netlify.app";
  late Ticket ticket;

  bool loading = false;
  String lastCode = '';

  Future<Ticket?> getTicketByQr(String qrCode) async {
    final response = await http.get(Uri.parse('$url/api/tickets/qr/$qrCode'),
        headers: {
          'Content-Type': 'application/json',
          'x-api-key': 'nateg-2025'
        });
    if (response.statusCode == 200) {
      final Map<String, dynamic> rawJson = jsonDecode(response.body);

      //print(rawJson);
      final scannedTicket = Ticket.fromJson(rawJson['data']);
      setState(() {
        ticket = scannedTicket;
        loading = false;
      });
      return scannedTicket;
    }
    return null;
  }

  bool manualSearchLoading = false;
  Future<void> getTicketByFullName(String query) async {
    loading = true;
    manualSearchLoading = true;
    final response = await http.get(Uri.parse('$url/api/tickets'), headers: {
      'Content-Type': 'application/json',
      'x-api-key': 'nateg-2025'
    });
    if (response.statusCode == 200) {
      final Map<String, dynamic> rawJson = jsonDecode(response.body);
      final List<dynamic> data = rawJson['data'];
      List<Ticket> tickets = [];
      tickets.clear();
      for (dynamic i in data) {
        tickets.add(Ticket.fromJson(i));
      }
      final matchingTicket = tickets.firstWhereOrNull(
        (t) =>
            t.spectator?.fullName.toLowerCase() == query.toLowerCase() ||
            t.attendee?.fullName.toLowerCase() == query.toLowerCase(),
      );

      if (matchingTicket != null) {
        Navigator.pushReplacementNamed(context, '/attendeeDetails',
            arguments: matchingTicket);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No ticket found for this name!'),
            backgroundColor: Colors.red,
          ),
        );
      }

      setState(() {
        loading = false;
        manualSearchLoading = false;
      });
    }
  }

  bool isScanned = false;

  @override
  void initState() {
    super.initState();
    scannerController.start();
    WidgetsBinding.instance.addObserver(this);
    checkPermission();
  }

  final TextEditingController _manualSearchController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        appBar: AppBar(
          backgroundColor: const Color.fromARGB(255, 255, 255, 255),
          title: const Center(
              child: Text(
            "Scan QR code",
            style: TextStyle(fontWeight: FontWeight.w600),
          )),
          automaticallyImplyLeading: false,
        ),
        body: SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildCard(
                  child: Column(
                    children: [
                      SizedBox(height: 10.h),
                      Container(
                        height: 320.h,
                        width: 320.w,
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Stack(children: [
                          MobileScanner(
                            controller: scannerController,
                            onDetect: (result) async {
                              if (isScanned) return;

                              final code = result.barcodes.first.rawValue;
                              if (code != null && code != lastCode) {
                                setState(() {
                                  isScanned = true;
                                  loading = true; // Shows your loading overlay
                                  lastCode = code;
                                });

                                // STOP the camera immediately
                                await scannerController.stop();

                                Ticket? chosenTicket =
                                    await getTicketByQr(code);

                                if (chosenTicket != null && mounted) {
                                  // Wait for user to come back from details
                                  Navigator.pushReplacementNamed(
                                    context,
                                    '/attendeeDetails',
                                    arguments: chosenTicket,
                                  );

                                  // Resume scanning when they return
                                  setState(() {
                                    isScanned = false;
                                    loading = false;
                                    lastCode = '';
                                  });
                                  scannerController.start();
                                } else {
                                  // Error case: Resume so they can try again
                                  setState(() {
                                    isScanned = false;
                                    loading = false;
                                  });
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                          'No ticket found for this qr code'),
                                    ),
                                  );
                                  scannerController.start();
                                }
                              }
                            },
                          ),
                          if (loading)
                            Container(
                              color: Colors.black.withOpacity(0.5),
                              child: const Center(
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                ),
                              ),
                            ),
                        ]),
                      ),
                      SizedBox(height: 10.h),
                      Text('Place the QR code within the frame',
                          style: TextStyle(fontSize: 16.sp)),
                    ],
                  ),
                ),
                SizedBox(height: 10.h),
                _buildCard(
                  child: Column(
                    children: [
                      Row(
                        children: [
                          SizedBox(width: 10.w),
                          Icon(Icons.search),
                          SizedBox(width: 10.w),
                          Text('Manual entry',
                              style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w600)),
                        ],
                      ),
                      SizedBox(height: 10.h),
                      SizedBox(
                        width: 310.w,
                        child: TextField(
                          controller: _manualSearchController,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Enter attendee\'s name',
                          ),
                        ),
                      ),
                      SizedBox(height: 15.h),
                      SizedBox(
                        width: 310.w,
                        height: 50.h,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color.fromARGB(255, 69, 48, 255),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                          ),
                          onPressed: () {
                            if (_manualSearchController.text.isNotEmpty) {
                              getTicketByFullName(_manualSearchController.text);
                            }
                          },
                          child: manualSearchLoading
                              ? Center(
                                  child: CircularProgressIndicator(),
                                )
                              : Text('Verify ticket',
                                  style: TextStyle(
                                      fontSize: 16.sp, color: Colors.white)),
                        ),
                      ),
                      SizedBox(height: 5.h),
                    ],
                  ),
                ),
                SizedBox(height: 20.h),
              ],
            ),
          ),
        ),
        bottomNavigationBar: const CustomBottomNav(activeIndex: 1),
      ),
    );
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      width: 360.w,
      padding: EdgeInsets.all(15.sp),
      margin: EdgeInsets.symmetric(horizontal: 15.w, vertical: 5.h),
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
      child: child,
    );
  }
}
