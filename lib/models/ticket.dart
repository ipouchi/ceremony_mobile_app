//import 'dart:io';

import 'package:ceremony/models/attendee.dart';
import 'package:ceremony/models/guest.dart';
import 'package:ceremony/models/spectator.dart';

class Ticket {
  final String id;
  String qrCode;
  bool paid;
  int price;
  String justification = '';
  bool nateger = false;
  Attendee? attendee;
  Spectator? spectator;
  List<Guest> guests;
  String? updatedAt;

  Ticket({
    required this.qrCode,
    required this.paid,
    required this.price,
    required this.justification,
    required this.nateger,
    this.attendee,
    this.spectator,
    this.guests = const [],
    required this.id,
    this.updatedAt,
  });

  factory Ticket.fromJson(Map<String, dynamic> json) {
    return Ticket(
      id: json['id'],
      qrCode: json['qrCode'],
      paid: json['paid'],
      price: json['price'],
      justification: json['justification'],
      nateger: json['nateger'],
      attendee:
          json['attendee'] != null ? Attendee.fromJson(json['attendee']) : null,
      spectator: json['spectator'] != null
          ? Spectator.fromJson(json['spectator'])
          : null,
      guests: json['guests'] != null
          ? (json['guests'] as List).map((i) => Guest.fromJson(i)).toList()
          : [],
      updatedAt: json['updatedAt'],
    );
  }

  /*Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'lastName': lastName,
      'userName': userName,
      'email': email,
      'phoneNumber': phone,
      'community_id': community,
      'birthDate': birthDate,
      'profilePicture': profilePicture?.path,
      'driverLicense': driverLicense?.path,
      'trusted': trusted,
      'status': status,
    };
  }*/
}
