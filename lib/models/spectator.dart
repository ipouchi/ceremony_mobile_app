//import 'dart:convert';

//import 'package:ceremony/models/ticket.dart';

class Spectator {
  final String id;
  final String fullName;
  final String email;
  final String phone;
  bool checkIn;
  final String ticketId;
  String? updatedAt;

  Spectator({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.checkIn,
    required this.ticketId,
    this.updatedAt,
  });

  factory Spectator.fromJson(Map<String, dynamic> json) => Spectator(
        id: json['id'],
        fullName: json['fullName'],
        email: json['email'],
        phone: json['phone'],
        checkIn: json['checkIn'] ?? false,
        ticketId: json['ticketId'],
        updatedAt: json['updatedAt'],
      );
  

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'email': email,
      'phone': phone,
      'checkIn': checkIn,
      'ticketId': ticketId,
    };
  }
}
