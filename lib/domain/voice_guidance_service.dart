import 'package:flutter_tts/flutter_tts.dart';

class VoiceGuidanceService {
  final FlutterTts _tts = FlutterTts();
  bool _enabled = true;
  DateTime _lastSpeakTime = DateTime.now();
  String _lastText = "";

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
    
    final now = DateTime.now();
    bool isUrgent = text.contains('!') || text.contains('Capture');
    
    // If text is same as last time, wait at least 5 seconds
    if (text == _lastText && now.difference(_lastSpeakTime).inSeconds < 5 && !isUrgent) {
      return;
    }
    
    // Minimum 3 second gap for any non-urgent speech
    if (now.difference(_lastSpeakTime).inSeconds < 3 && !isUrgent) {
      return;
    }

    _lastText = text;
    _lastSpeakTime = now;
    await _tts.speak(text);
  }

  Future<void> stop() async {
    await _tts.stop();
  }
}
