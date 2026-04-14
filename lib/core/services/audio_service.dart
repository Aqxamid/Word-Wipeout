// lib/core/services/audio_service.dart
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

class AudioService {
  late final AudioPlayer _actionPlayer;

  // Configuration
  bool _isMuted = false;

  bool get isMuted => _isMuted;

  void toggleMute() {
    _isMuted = !_isMuted;
  }

  Future<void> init() async {
    _actionPlayer = AudioPlayer();
    await _actionPlayer.setPlayerMode(PlayerMode.lowLatency);
  }

  void dispose() {
    _actionPlayer.dispose();
  }

  // Define actual mp3 file names you'll place in `assets/sounds/`
  // Make sure to add e.g. `assets/sounds/typing.mp3` or similar.

  Future<void> playTyping() async {
    if (_isMuted) return;
    try {
      final p = AudioPlayer();
      p.play(AssetSource('sounds/typing.mp3'), volume: 0.3).then((_) {
        // Ephemeral gc
        Future.delayed(const Duration(seconds: 1), () => p.dispose());
      });
    } catch (e) {
      debugPrint('Audio missing: typing.mp3');
    }
  }

  Future<void> playCorrect() async {
    if (_isMuted) return;
    try {
      await _actionPlayer.play(AssetSource('sounds/correct.mp3'), volume: 0.7);
    } catch (e) {
      debugPrint('Audio missing: correct.mp3');
    }
  }

  Future<void> playWrong() async {
    if (_isMuted) return;
    try {
      await _actionPlayer.play(AssetSource('sounds/wrong.mp3'), volume: 0.7);
    } catch (e) {
      debugPrint('Audio missing: wrong.mp3');
    }
  }

  Future<void> playWin() async {
    if (_isMuted) return;
    try {
      await _actionPlayer.play(AssetSource('sounds/win.mp3'), volume: 1.0);
    } catch (e) {
      debugPrint('Audio missing: win.mp3');
    }
  }

  Future<void> playLose() async {
    if (_isMuted) return;
    try {
      await _actionPlayer.play(AssetSource('sounds/lose.mp3'), volume: 1.0);
    } catch (e) {
      debugPrint('Audio missing: lose.mp3');
    }
  }

  Future<void> playRageLose() async {
    if (_isMuted) return;
    try {
      await _actionPlayer.play(AssetSource('sounds/rage_lose.mp3'), volume: 1.0);
    } catch (e) {
      debugPrint('Audio missing: rage_lose.mp3');
    }
  }
}
