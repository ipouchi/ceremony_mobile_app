import 'participant.dart';

class Team {
  final int id;
  final String name;
  final String code;
  final int expectedSize;
  final List<Participant>? participants;
  int numberOfCheckedIn;
  final DateTime createdAt;
  final DateTime updatedAt;

  Team({
    required this.id,
    required this.name,
    required this.code,
    required this.expectedSize,
    this.participants,
    required this.createdAt,
    required this.updatedAt,
    this.numberOfCheckedIn = 0,
  });

  factory Team.fromJson(Map<String, dynamic> json) => Team(
        id: json['id'],
        name: json['name'],
        code: json['code'],
        expectedSize: json['expectedSize'],
        participants: json['participants'] != null
            ? List<Participant>.from(
                json['participants'].map((x) => Participant.fromJson(x)))
            : null,
        numberOfCheckedIn: json['numberOfCheckedIn'],
        createdAt: DateTime.parse(json['createdAt']),
        updatedAt: DateTime.parse(json['updatedAt']),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'code': code,
        'expectedSize': expectedSize,
        'numberOfCheckedIn': numberOfCheckedIn,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };
}
