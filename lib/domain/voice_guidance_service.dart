import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    
    final prefs = await SharedPreferences.getInstance();
    final style = prefs.getString('pro_voice_style') ?? 'director';
    
    // Transform text based on selected voice actor style
    String transformedText = text;
    
    if (style == 'director') {
      if (text.toLowerCase().contains('capture') || text.toLowerCase().contains('awesome')) {
        transformedText = "Fabulous capture! Absolutely darling.";
      } else {
        transformedText = "Work it, darling! $text. Gorgeous!";
      }
    } else if (style == 'yogi') {
      if (text.toLowerCase().contains('capture') || text.toLowerCase().contains('awesome')) {
        transformedText = "Mindful capture. Beautiful peace.";
      } else {
        transformedText = "Breathe in... gently $text... breathe out.";
      }
    } else if (style == 'cyber') {
      if (text.toLowerCase().contains('capture') || text.toLowerCase().contains('awesome')) {
        transformedText = "Capture protocol completed. Frame stored.";
      } else {
        transformedText = "Calibrating posture... alert: $text. Command status pending.";
      }
    }
    
    final now = DateTime.now();
    bool isUrgent = text.contains('!') || text.contains('Capture') || text.contains('Awesome');
    
    // If text is same as last time, wait at least 5 seconds
    if (transformedText == _lastText && now.difference(_lastSpeakTime).inSeconds < 5 && !isUrgent) {
      return;
    }
    
    // Minimum 3 second gap for any non-urgent speech
    if (now.difference(_lastSpeakTime).inSeconds < 3 && !isUrgent) {
      return;
    }

    _lastText = transformedText;
    _lastSpeakTime = now;
    await _tts.speak(transformedText);
  }

  Future<void> stop() async {
    await _tts.stop();
  }
}
