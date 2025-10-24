import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:http/http.dart' as http;

/// Service for handling Gemini AI-powered surroundings detection
/// Provides camera capture, image analysis, and text-to-speech functionality
class GeminiService {
  static const String _defaultServerUrl = "http://192.168.68.53:3000/describe";
  
  final FlutterTts _tts = FlutterTts();
  Timer? _timer;
  bool _isRunning = false;
  bool _isProcessing = false;
  String _lastDescription = "";
  String _serverUrl = _defaultServerUrl;

  // Getters for state
  bool get isRunning => _isRunning;
  bool get isProcessing => _isProcessing;
  String get lastDescription => _lastDescription;

  /// Initialize the TTS service
  Future<void> initialize() async {
    await _tts.setLanguage("en-US");
    await _tts.setSpeechRate(0.8);
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.0);
  }

  /// Set custom server URL for Gemini API
  void setServerUrl(String url) {
    _serverUrl = url;
  }

  /// Capture image from camera and send to Gemini for analysis
  Future<String> captureAndDescribe(CameraController controller) async {
    if (!controller.value.isInitialized || _isProcessing) {
      return _lastDescription;
    }

    _isProcessing = true;

    try {
      // Check if camera is still active
      if (!controller.value.isInitialized) {
        return "Camera not ready";
      }

      final picture = await controller.takePicture();
      final bytes = await picture.readAsBytes();
      final base64Image = base64Encode(bytes);

      // Clean up the temporary file
      final file = File(picture.path);
      if (await file.exists()) await file.delete();

      final response = await http.post(
        Uri.parse(_serverUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'imageBase64': base64Image}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final description = data['description'] ?? "No objects detected.";
        
        if (description != _lastDescription) {
          _lastDescription = description;
          await _tts.speak(description);
        }
        
        return description;
      } else {
        return "Server error: ${response.statusCode}";
      }
    } catch (e) {
      return "Error: ${e.toString().substring(0, 50)}...";
    } finally {
      _isProcessing = false;
    }
  }

  /// Start continuous vision analysis
  void startVision(CameraController controller, {Duration interval = const Duration(seconds: 3)}) {
    if (_isRunning) return;
    
    _timer = Timer.periodic(interval, (_) => captureAndDescribe(controller));
    _isRunning = true;
  }

  /// Stop continuous vision analysis
  void stopVision() {
    _timer?.cancel();
    _isRunning = false;
  }

  /// Dispose resources
  void dispose() {
    _timer?.cancel();
    _tts.stop();
  }
}
