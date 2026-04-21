import 'package:flutter_tts/flutter_tts.dart';

class VoiceGuidanceService {
  final FlutterTts _tts = FlutterTts();
  bool _enabled = true;
  DateTime _lastSpeakTime = DateTime.now();

  VoiceGuidanceService() {
    _initTts();
  }

  Future<void> _initTts() async {
    await _tts.setLanguage("en-US");
    await _tts.setSpeechRate(0.5);
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.1); // Slightly higher for a friendly female voice

    // Attempt to set a natural female voice if available
    try {
      final voices = await _tts.getVoices;
      for (final voice in voices) {
        if (voice['name'].toString().toLowerCase().contains('female') || 
            voice['name'].toString().toLowerCase().contains('en-us-x-sfg')) {
          await _tts.setVoice({"name": voice['name'], "locale": voice['locale']});
          break;
        }
      }
    } catch (e) {
      // Fallback to default
    }
  }

  void toggle(bool enabled) {
    _enabled = enabled;
    if (!enabled) _tts.stop();
  }

  Future<void> speak(String text) async {
    if (!_enabled) return;
    
    // Throttle voice to avoid overlapping and annoyance
    final now = DateTime.now();
    if (now.difference(_lastSpeakTime).inSeconds < 3 && !text.contains('!')) {
      return;
    }

    _lastSpeakTime = now;
    await _tts.speak(text);
  }

  Future<void> stop() async {
    await _tts.stop();
  }
}
