import 'package:audioplayers/audioplayers.dart';

class AudioManager {
  static final AudioPlayer _player = AudioPlayer();
  static bool _isPlaying = false;

  static Future<void> playBackground() async {
    if (!_isPlaying) {
      await _player.setReleaseMode(ReleaseMode.loop);
      await _player.play(AssetSource("audio/Flappy_Bird.mp3"));
      _isPlaying = true;
    }
  }

  static Future<void> pauseBackground() async {
    if (_isPlaying) {
      await _player.pause();
      _isPlaying = false;
    }
  }

  static Future<void> resumeBackground() async {
    if (!_isPlaying) {
      await _player.resume();
      _isPlaying = true;
    }
  }

  static bool get isPlaying => _isPlaying;

  static Future<void> stop() async {
    await _player.stop();
    _isPlaying = false;
  }
}
