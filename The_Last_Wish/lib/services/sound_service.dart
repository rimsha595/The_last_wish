import 'package:audioplayers/audioplayers.dart';

class SoundService {
  static final AudioPlayer _player = AudioPlayer();

  static Future<void> play(String file) async {
    await _player.play(AssetSource(file));
  }

  static Future<void> heartbeat() => play("sounds/heartbeat.mp3");
  static Future<void> whisper() => play("sounds/whisper.mp3");
  static Future<void> end() => play("sounds/end.mp3");

  static Future<void> stop() async {
    await _player.stop();
  }
}
