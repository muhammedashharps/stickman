import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  final AudioPlayer _player = AudioPlayer();
  bool _isMuted = false;

  bool get isMuted => _isMuted;

  void toggleMute() {
    _isMuted = !_isMuted;
  }

  /// Play success sound when timer/animation completes
  Future<void> playSuccessSound() async {
    if (_isMuted) return;

    try {
      await _player.stop();
      await _player.play(AssetSource('sounds/game-success.mp3'));
    } catch (e) {
      debugPrint('Error playing success sound: $e');
    }
  }

  Future<void> playSound(String filename) async {
    if (_isMuted) return;

    try {
      await _player.stop();
      await _player.play(AssetSource('sounds/$filename'));
    } catch (e) {
      debugPrint('Error playing sound $filename: $e');
    }
  }

  /// Dispose the audio player
  void dispose() {
    _player.dispose();
  }
}
