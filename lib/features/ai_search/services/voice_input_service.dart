// ignore_for_file: avoid_print, deprecated_member_use

import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter/material.dart';

/// Voice Input Service
/// Handles voice-to-text for AI queries and text-to-speech for reading
class VoiceInputService {
  final stt.SpeechToText _speech = stt.SpeechToText();
  final FlutterTts _tts = FlutterTts();
  bool _isListening = false;
  bool _isInitialized = false;

  bool get isListening => _isListening;
  bool get isInitialized => _isInitialized;

  /// Initialize speech recognition
  Future<bool> initialize() async {
    try {
      _isInitialized = await _speech.initialize(
        onStatus: (status) => print('Speech status: $status'),
        onError: (error) => print('Speech error: $error'),
      );

      // Initialize TTS
      await _tts.setLanguage('en-US');
      await _tts.setSpeechRate(0.5);
      await _tts.setVolume(1.0);
      await _tts.setPitch(1.0);

      return _isInitialized;
    } catch (e) {
      print('Error initializing voice service: $e');
      return false;
    }
  }

  /// Start listening for voice input
  Future<void> startListening({
    required Function(String) onResult,
    String? localeId,
  }) async {
    if (!_isInitialized) {
      await initialize();
    }

    if (!_isInitialized) {
      print('Speech recognition not available');
      return;
    }

    _isListening = true;

    await _speech.listen(
      onResult: (result) {
        if (result.finalResult) {
          final text = result.recognizedWords;
          onResult(text);
          _isListening = false;
        }
      },
      localeId: localeId,
      listenMode: stt.ListenMode.confirmation,
      cancelOnError: true,
      partialResults: true,
    );
  }

  /// Stop listening
  Future<void> stopListening() async {
    if (_isListening) {
      await _speech.stop();
      _isListening = false;
    }
  }

  /// Cancel listening
  Future<void> cancelListening() async {
    if (_isListening) {
      await _speech.cancel();
      _isListening = false;
    }
  }

  /// Text-to-Speech - Read text aloud
  Future<void> speak(String text) async {
    try {
      await _tts.speak(text);
    } catch (e) {
      print('Error speaking: $e');
    }
  }

  /// Stop speaking
  Future<void> stopSpeaking() async {
    await _tts.stop();
  }

  /// Pause speaking
  Future<void> pauseSpeaking() async {
    await _tts.pause();
  }

  /// Set speech rate (0.0 - 1.0)
  Future<void> setSpeechRate(double rate) async {
    await _tts.setSpeechRate(rate);
  }

  /// Set volume (0.0 - 1.0)
  Future<void> setVolume(double volume) async {
    await _tts.setVolume(volume);
  }

  /// Set pitch (0.5 - 2.0)
  Future<void> setPitch(double pitch) async {
    await _tts.setPitch(pitch);
  }

  /// Get available languages
  Future<List<String>> getAvailableLanguages() async {
    return await _speech.locales().then((locales) {
      return locales.map((locale) => locale.localeId).toList();
    });
  }

  /// Check if speech recognition is available
  Future<bool> isAvailable() async {
    return await _speech.initialize();
  }

  void dispose() {
    _speech.cancel();
    _tts.stop();
  }
}

/// Voice Input Widget for AI Chat

class VoiceInputButton extends StatefulWidget {
  final Function(String) onResult;
  final VoiceInputService? voiceService;

  const VoiceInputButton({
    super.key,
    required this.onResult,
    this.voiceService,
  });

  @override
  State<VoiceInputButton> createState() => _VoiceInputButtonState();
}

class _VoiceInputButtonState extends State<VoiceInputButton>
    with SingleTickerProviderStateMixin {
  late VoiceInputService _voiceService;
  late AnimationController _animationController;
  bool _isListening = false;

  @override
  void initState() {
    super.initState();
    _voiceService = widget.voiceService ?? VoiceInputService();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    if (widget.voiceService == null) {
      _voiceService.dispose();
    }
    super.dispose();
  }

  Future<void> _toggleListening() async {
    if (_isListening) {
      await _voiceService.stopListening();
      setState(() {
        _isListening = false;
      });
      _animationController.stop();
    } else {
      final isAvailable = await _voiceService.initialize();

      if (!isAvailable) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Speech recognition not available'),
            ),
          );
        }
        return;
      }

      setState(() {
        _isListening = true;
      });
      _animationController.repeat(reverse: true);

      await _voiceService.startListening(
        onResult: (text) {
          widget.onResult(text);
          setState(() {
            _isListening = false;
          });
          _animationController.stop();
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggleListening,
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _isListening
                  ? Theme.of(context).primaryColor.withOpacity(
                        0.3 + (_animationController.value * 0.3),
                      )
                  : Theme.of(context).primaryColor.withOpacity(0.1),
              border: Border.all(
                color: Theme.of(context).primaryColor,
                width: 2,
              ),
            ),
            child: Icon(
              _isListening ? Icons.mic : Icons.mic_none,
              color: Theme.of(context).primaryColor,
              size: 28,
            ),
          );
        },
      ),
    );
  }
}
