import 'package:ceremony/models/team.dart';

class Participant {
  final int id;
  final String fullName;
  final String email;
  final String phone;
  final String faculty;
  final String fieldAndYear;
  final String ticket;
  final bool isCreator;
  final bool paid;
  final String? paymentProof;
  final int? teamId;
  final Team? team;
  bool checkedIn;
  final DateTime createdAt;
  final DateTime updatedAt;

  Participant({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.faculty,
    required this.fieldAndYear,
    required this.ticket,
    this.isCreator = false,
    this.paid = false,
    this.paymentProof,
    this.teamId,
    this.team,
    this.checkedIn = false,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Participant.fromJson(Map<String, dynamic> json) => Participant(
        id: json['id'],
        fullName: json['fullName'],
        email: json['email'],
        phone: json['phone'],
        faculty: json['faculty'],
        fieldAndYear: json['fieldAndYear'],
        ticket: json['ticket'],
        isCreator: json['isCreator'] ?? false,
        paid: json['paid'] ?? false,
        paymentProof: json['paymentProof'],
        teamId: json['teamId'],
        team: json['team'] != null ? Team.fromJson(json['team']) : null,
        checkedIn: json['checkedIn']?? false,
        createdAt: DateTime.parse(json['createdAt']),
        updatedAt: DateTime.parse(json['updatedAt']),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'fullName': fullName,
        'email': email,
        'phone': phone,
        'faculty': faculty,
        'fieldAndYear': fieldAndYear,
        'ticket': ticket,
        'isCreator': isCreator,
        'paid': paid,
        'paymentProof': paymentProof,
        'teamId': teamId,
        'checkedIn': checkedIn,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };
}
