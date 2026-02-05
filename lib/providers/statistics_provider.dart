import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/focus_session.dart';

class StatisticsProvider extends ChangeNotifier {
  List<FocusSession> _sessions = [];
  bool _isLoading = true;

  List<FocusSession> get sessions => List.unmodifiable(_sessions);
  bool get isLoading => _isLoading;
  bool get isLoaded => !_isLoading;

  int get totalSessions => _sessions.length;
  int get completedSessions => _sessions.where((s) => s.wasCompleted).length;
  int get totalFocusMinutes =>
      _sessions.fold(0, (sum, s) => sum + (s.durationSeconds ~/ 60));

  double get completionRate {
    if (_sessions.isEmpty) return 0;
    return completedSessions / totalSessions;
  }

  List<FocusSession> get todaySessions {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return _sessions.where((s) {
      final sessionDate = DateTime(
        s.completedAt.year,
        s.completedAt.month,
        s.completedAt.day,
      );
      return sessionDate == today;
    }).toList();
  }

  List<FocusSession> get thisWeekSessions {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekStartDate = DateTime(
      weekStart.year,
      weekStart.month,
      weekStart.day,
    );
    return _sessions
        .where((s) => s.completedAt.isAfter(weekStartDate))
        .toList();
  }

  StatisticsProvider() {
    _loadSessions();
  }

  Future<void> _loadSessions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final sessionsJson = prefs.getStringList('focus_sessions') ?? [];
      _sessions = sessionsJson
          .map((json) => FocusSession.fromJson(jsonDecode(json)))
          .toList();
      _sessions.sort((a, b) => b.completedAt.compareTo(a.completedAt));
    } catch (e) {
      debugPrint('Error loading sessions: $e');
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> _saveSessions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final sessionsJson = _sessions
          .map((s) => jsonEncode(s.toJson()))
          .toList();
      await prefs.setStringList('focus_sessions', sessionsJson);
    } catch (e) {
      debugPrint('Error saving sessions: $e');
    }
  }

  Future<void> addSession(FocusSession session) async {
    _sessions.insert(0, session);
    notifyListeners();
    await _saveSessions();
  }

  Future<void> deleteSession(String id) async {
    _sessions.removeWhere((s) => s.id == id);
    notifyListeners();
    await _saveSessions();
  }

  Future<void> clearAllSessions() async {
    _sessions.clear();
    notifyListeners();
    await _saveSessions();
  }

  Map<DateTime, int> getSessionsByDay() {
    final Map<DateTime, int> result = {};
    for (final session in _sessions) {
      final date = DateTime(
        session.completedAt.year,
        session.completedAt.month,
        session.completedAt.day,
      );
      result[date] = (result[date] ?? 0) + 1;
    }
    return result;
  }

  int getLongestStreak() {
    if (_sessions.isEmpty) return 0;

    final uniqueDays = getSessionsByDay().keys.toList()
      ..sort((a, b) => a.compareTo(b));

    if (uniqueDays.isEmpty) return 0;

    int maxStreak = 1;
    int currentStreak = 1;

    for (int i = 1; i < uniqueDays.length; i++) {
      final diff = uniqueDays[i].difference(uniqueDays[i - 1]).inDays;
      if (diff == 1) {
        currentStreak++;
        maxStreak = currentStreak > maxStreak ? currentStreak : maxStreak;
      } else {
        currentStreak = 1;
      }
    }

    return maxStreak;
  }

  /// Get current streak (consecutive days including today/yesterday)
  int get currentStreak {
    if (_sessions.isEmpty) return 0;

    final uniqueDays = getSessionsByDay().keys.toList()
      ..sort((a, b) => b.compareTo(a)); // Most recent first

    if (uniqueDays.isEmpty) return 0;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    // Check if there's a session today or yesterday
    if (uniqueDays.first != today && uniqueDays.first != yesterday) {
      return 0;
    }

    int streak = 1;
    for (int i = 1; i < uniqueDays.length; i++) {
      final diff = uniqueDays[i - 1].difference(uniqueDays[i]).inDays;
      if (diff == 1) {
        streak++;
      } else {
        break;
      }
    }
    return streak;
  }

  /// Get weekly data as a map of DateTime to hours
  Map<DateTime, double> get weeklyData {
    final now = DateTime.now();
    final Map<DateTime, double> result = {};

    // Get start of this week (Monday)
    final weekStart = now.subtract(Duration(days: now.weekday - 1));

    for (int i = 0; i < 7; i++) {
      final day = DateTime(weekStart.year, weekStart.month, weekStart.day + i);
      result[day] = hoursForDay(day);
    }

    return result;
  }

  /// Get sessions for a specific day
  List<FocusSession> sessionsForDay(DateTime date) {
    final targetDate = DateTime(date.year, date.month, date.day);
    return _sessions.where((s) {
      final sessionDate = DateTime(
        s.completedAt.year,
        s.completedAt.month,
        s.completedAt.day,
      );
      return sessionDate == targetDate;
    }).toList();
  }

  /// Get total hours for a specific day
  double hoursForDay(DateTime date) {
    final targetDate = DateTime(date.year, date.month, date.day);
    final daySessions = _sessions.where((s) {
      final sessionDate = DateTime(
        s.completedAt.year,
        s.completedAt.month,
        s.completedAt.day,
      );
      return sessionDate == targetDate;
    });

    final totalSeconds = daySessions.fold<int>(
      0,
      (sum, s) => sum + s.durationSeconds,
    );
    return totalSeconds / 3600.0;
  }
}
