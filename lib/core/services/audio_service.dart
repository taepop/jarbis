import 'package:just_audio/just_audio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AudioService {
  static final AudioPlayer _player = AudioPlayer();
  static const String _defaultSoundKey = 'default_alarm_sound';

  static AudioPlayer get player => _player;

  /// Initialize audio player
  static Future<void> initialize() async {
    await _player.setLoopMode(LoopMode.one);
  }

  /// Pick audio file from device
  static Future<String?> pickAudioFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.audio,
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        return result.files.first.path;
      }
    } catch (e) {
      print('Error picking audio file: $e');
    }
    return null;
  }

  /// Save default alarm sound path
  static Future<void> setDefaultSound(String path) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_defaultSoundKey, path);
  }

  /// Get default alarm sound path
  static Future<String?> getDefaultSound() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_defaultSoundKey);
  }

  /// Play alarm sound
  static Future<void> playAlarm(String? soundPath) async {
    try {
      if (soundPath != null && soundPath.isNotEmpty) {
        await _player.setFilePath(soundPath);
      } else {
        // Use default system sound or bundled sound
        final defaultPath = await getDefaultSound();
        if (defaultPath != null) {
          await _player.setFilePath(defaultPath);
        } else {
          // Fallback: play a simple tone (you could add a bundled asset)
          print('No alarm sound configured');
          return;
        }
      }

      await _player.setVolume(1.0);
      await _player.setLoopMode(LoopMode.one);
      await _player.play();
    } catch (e) {
      print('Error playing alarm: $e');
    }
  }

  /// Stop alarm sound
  static Future<void> stopAlarm() async {
    await _player.stop();
  }

  /// Pause alarm sound (for briefing)
  static Future<void> pauseAlarm() async {
    await _player.pause();
  }

  /// Resume alarm sound
  static Future<void> resumeAlarm() async {
    await _player.play();
  }

  /// Set volume
  static Future<void> setVolume(double volume) async {
    await _player.setVolume(volume.clamp(0.0, 1.0));
  }

  /// Lower volume for briefing
  static Future<void> lowerVolumeForBriefing() async {
    await _player.setVolume(0.2);
  }

  /// Restore normal volume
  static Future<void> restoreVolume() async {
    await _player.setVolume(1.0);
  }

  /// Check if playing
  static bool get isPlaying => _player.playing;

  /// Dispose player
  static Future<void> dispose() async {
    await _player.dispose();
  }
}
