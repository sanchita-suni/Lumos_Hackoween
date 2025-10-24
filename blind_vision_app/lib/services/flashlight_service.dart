import 'package:torch_light/torch_light.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_tts/flutter_tts.dart';

/// Service for handling flashlight functionality with voice control
/// Provides torch control and speech recognition for voice commands
class FlashlightService {
  final FlutterTts _tts = FlutterTts();
  bool _isOn = false;
  bool _isListening = false;

  // Getters for state
  bool get isOn => _isOn;
  bool get isListening => _isListening;

  /// Initialize the TTS service
  Future<void> initialize() async {
    await _tts.setLanguage("en-US");
    await _tts.setSpeechRate(0.8);
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.0);
  }

  /// Check and request camera permission (required for flashlight)
  Future<bool> requestPermission() async {
    final status = await Permission.camera.request();
    return status.isGranted;
  }

  /// Toggle flashlight on/off
  Future<bool> toggleFlashlight() async {
    try {
      if (_isOn) {
        await TorchLight.disableTorch();
        _isOn = false;
        await _tts.speak("Flashlight off");
      } else {
        await TorchLight.enableTorch();
        _isOn = true;
        await _tts.speak("Flashlight on");
      }
      return true;
    } catch (e) {
      await _tts.speak("Flashlight error: ${e.toString()}");
      return false;
    }
  }

  /// Turn flashlight on
  Future<bool> turnOn() async {
    try {
      if (!_isOn) {
        await TorchLight.enableTorch();
        _isOn = true;
        await _tts.speak("Flashlight on");
      }
      return true;
    } catch (e) {
      await _tts.speak("Failed to turn on flashlight");
      return false;
    }
  }

  /// Turn flashlight off
  Future<bool> turnOff() async {
    try {
      if (_isOn) {
        await TorchLight.disableTorch();
        _isOn = false;
        await _tts.speak("Flashlight off");
      }
      return true;
    } catch (e) {
      await _tts.speak("Failed to turn off flashlight");
      return false;
    }
  }

  /// Process voice command for flashlight control
  Future<void> processVoiceCommand(String command) async {
    final lowerCommand = command.toLowerCase();
    
    if (lowerCommand.contains('on') || lowerCommand.contains('turn on')) {
      await turnOn();
    } else if (lowerCommand.contains('off') || lowerCommand.contains('turn off')) {
      await turnOff();
    } else if (lowerCommand.contains('toggle') || lowerCommand.contains('switch')) {
      await toggleFlashlight();
    } else {
      await _tts.speak("Command not recognized. Say 'turn on', 'turn off', or 'toggle'");
    }
  }

  /// Dispose resources
  void dispose() {
    _tts.stop();
  }
}
