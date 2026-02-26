//import 'dart:convert';

//import 'package:ceremony/models/ticket.dart';

class Guest {
  final String id;
  final String fullName;
  bool checkIn;
  final String ticketId;
  // final Ticket ticket;

  Guest({
    required this.id,
    required this.fullName,
    required this.checkIn,
    required this.ticketId,
    //required this.ticket,
  });

  factory Guest.fromJson(Map<String, dynamic> json) => Guest(
        id: json['id'],
        fullName: json['fullName'],
        checkIn: json['checkIn'] ?? false,
        ticketId: json['ticketId'],
        //ticket: Ticket.fromJson(json['ticket']),
      );
}
