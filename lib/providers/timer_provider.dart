import 'dart:async';
import 'package:flutter/material.dart';
import '../services/audio_service.dart';

/// Timer state management for productivity timer
/// Uses DateTime-based timing to correctly handle background/screen-off scenarios
class TimerProvider extends ChangeNotifier with WidgetsBindingObserver {
  int _totalDuration = 25 * 60; // Default 25 minutes (in seconds)

  Timer? _timer;
  bool _isRunning = false;
  bool _isCompleted = false;

  /// The time when the timer was last started/resumed
  DateTime? _startTime;

  /// Remaining seconds when timer was last paused
  int _pausedRemainingSeconds = 25 * 60;

  final AudioService _audioService = AudioService();

  TimerProvider() {
    WidgetsBinding.instance.addObserver(this);
  }

  int get totalDuration => _totalDuration;

  /// Calculate remaining time based on actual elapsed time
  int get remainingTime {
    if (!_isRunning || _startTime == null) {
      return _pausedRemainingSeconds;
    }

    final elapsed = DateTime.now().difference(_startTime!).inSeconds;
    final remaining = _pausedRemainingSeconds - elapsed;
    return remaining > 0 ? remaining : 0;
  }

  bool get isRunning => _isRunning;
  bool get isCompleted => _isCompleted;

  double get progress {
    if (_totalDuration == 0) return 0.0;
    return 1.0 - (remainingTime / _totalDuration);
  }

  String get displayTime {
    final time = remainingTime;
    final minutes = (time ~/ 60).toString().padLeft(2, '0');
    final seconds = (time % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  void setDuration(int minutes) {
    if (_isRunning) return;

    _totalDuration = minutes * 60;
    _pausedRemainingSeconds = _totalDuration;
    _isCompleted = false;
    notifyListeners();
  }

  void start() {
    if (_isRunning || _isCompleted) return;

    _startTime = DateTime.now();
    _isRunning = true;

    // Use a fast timer just for UI updates, actual time is calculated from DateTime
    _timer = Timer.periodic(const Duration(milliseconds: 500), _tick);
    notifyListeners();
  }

  void pause() {
    if (!_isRunning) return;

    // Store how much time was remaining when paused
    _pausedRemainingSeconds = remainingTime;
    _startTime = null;
    _timer?.cancel();
    _timer = null;
    _isRunning = false;
    notifyListeners();
  }

  void toggleTimer() {
    if (_isRunning) {
      pause();
    } else {
      start();
    }
  }

  void reset() {
    _timer?.cancel();
    _timer = null;
    _startTime = null;
    _isRunning = false;
    _isCompleted = false;
    _pausedRemainingSeconds = _totalDuration;
    notifyListeners();
  }

  void _tick(Timer timer) {
    final remaining = remainingTime;

    if (remaining > 0) {
      notifyListeners();
    } else {
      // Timer completed!
      _timer?.cancel();
      _timer = null;
      _startTime = null;
      _isRunning = false;
      _isCompleted = true;
      _pausedRemainingSeconds = 0;

      _audioService.playSuccessSound();

      notifyListeners();
    }
  }

  /// Called when app lifecycle changes (background/foreground)
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _isRunning) {
      // App came back to foreground - recalculate and update UI
      notifyListeners();

      // Check if timer should have completed while in background
      if (remainingTime <= 0 && !_isCompleted) {
        _timer?.cancel();
        _timer = null;
        _startTime = null;
        _isRunning = false;
        _isCompleted = true;
        _pausedRemainingSeconds = 0;
        _audioService.playSuccessSound();
        notifyListeners();
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    super.dispose();
  }
}
