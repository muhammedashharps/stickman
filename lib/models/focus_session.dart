import 'dart:convert';

class FocusSession {
  final String id;
  final String scenario;
  final int durationSeconds;
  final DateTime completedAt;
  final bool wasCompleted;

  FocusSession({
    required this.id,
    required this.scenario,
    required this.durationSeconds,
    required this.completedAt,
    required this.wasCompleted,
  });

  /// Time in minutes
  double get durationMinutes => durationSeconds / 60;

  /// Time in hours
  double get durationHours => durationSeconds / 3600;

  Map<String, dynamic> toJson() => {
    'id': id,
    'scenario': scenario,
    'durationSeconds': durationSeconds,
    'completedAt': completedAt.toIso8601String(),
    'wasCompleted': wasCompleted,
  };

  factory FocusSession.fromJson(Map<String, dynamic> json) => FocusSession(
    id: json['id'] as String,
    scenario: json['scenario'] as String,
    durationSeconds: json['durationSeconds'] as int,
    completedAt: DateTime.parse(json['completedAt'] as String),
    wasCompleted: json['wasCompleted'] as bool,
  );

  static List<FocusSession> listFromJson(String jsonString) {
    if (jsonString.isEmpty) return [];
    final List<dynamic> jsonList = jsonDecode(jsonString);
    return jsonList
        .map((e) => FocusSession.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  static String listToJson(List<FocusSession> sessions) {
    return jsonEncode(sessions.map((e) => e.toJson()).toList());
  }
}
