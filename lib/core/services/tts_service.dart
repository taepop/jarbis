import 'package:flutter_tts/flutter_tts.dart';

class TtsService {
  static final FlutterTts _tts = FlutterTts();
  static bool _isInitialized = false;
  static bool _isSpeaking = false;

  /// Initialize TTS engine
  static Future<void> initialize() async {
    if (_isInitialized) return;

    await _tts.setLanguage('en-US');
    await _tts.setSpeechRate(0.45); // Slightly slower for clarity
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.0);

    // Try to find a suitable voice
    final voices = await _tts.getVoices;
    if (voices is List) {
      // Look for a male English voice for JARVIS feel
      for (final voice in voices) {
        if (voice is Map) {
          final name = voice['name']?.toString().toLowerCase() ?? '';
          final locale = voice['locale']?.toString().toLowerCase() ?? '';
          
          if (locale.contains('en') && 
              (name.contains('male') || name.contains('david') || name.contains('james'))) {
            await _tts.setVoice({'name': voice['name'], 'locale': voice['locale']});
            break;
          }
        }
      }
    }

    _tts.setCompletionHandler(() {
      _isSpeaking = false;
    });

    _tts.setErrorHandler((message) {
      print('TTS Error: $message');
      _isSpeaking = false;
    });

    _isInitialized = true;
  }

  /// Speak text
  static Future<void> speak(String text) async {
    if (!_isInitialized) await initialize();
    
    _isSpeaking = true;
    await _tts.speak(text);
  }

  /// Stop speaking
  static Future<void> stop() async {
    _isSpeaking = false;
    await _tts.stop();
  }

  /// Pause speaking
  static Future<void> pause() async {
    await _tts.pause();
  }

  /// Check if speaking
  static bool get isSpeaking => _isSpeaking;

  /// Set speech rate (0.0 - 1.0)
  static Future<void> setSpeechRate(double rate) async {
    await _tts.setSpeechRate(rate.clamp(0.0, 1.0));
  }

  /// Set volume (0.0 - 1.0)
  static Future<void> setVolume(double volume) async {
    await _tts.setVolume(volume.clamp(0.0, 1.0));
  }

  /// Set completion handler
  static void setCompletionHandler(Function() handler) {
    _tts.setCompletionHandler(handler);
  }

  /// Speak morning briefing
  static Future<void> speakMorningBriefing({
    required String weatherBriefing,
    required String newsBriefing,
    Function()? onComplete,
  }) async {
    if (!_isInitialized) await initialize();

    final greeting = _getTimeBasedGreeting();
    
    final fullBriefing = '''
$greeting

$weatherBriefing

$newsBriefing
''';

    if (onComplete != null) {
      _tts.setCompletionHandler(() {
        _isSpeaking = false;
        onComplete();
      });
    }

    await speak(fullBriefing);
  }

  /// Get greeting based on time of day
  static String _getTimeBasedGreeting() {
    final hour = DateTime.now().hour;
    
    if (hour < 12) {
      return 'Good morning, sir.';
    } else if (hour < 17) {
      return 'Good afternoon, sir.';
    } else {
      return 'Good evening, sir.';
    }
  }
}
