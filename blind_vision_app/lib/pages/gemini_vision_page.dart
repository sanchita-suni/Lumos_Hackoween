import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/gemini_service.dart';

/// Gemini Vision page for AI-powered surroundings detection
/// Refactored from the original LiveVision implementation with improved UI
class GeminiVisionPage extends StatefulWidget {
  const GeminiVisionPage({super.key});

  @override
  State<GeminiVisionPage> createState() => _GeminiVisionPageState();
}

class _GeminiVisionPageState extends State<GeminiVisionPage> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  final GeminiService _geminiService = GeminiService();
  
  String _status = "Initializing camera...";
  String _description = "";
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _geminiService.initialize();
  }

  /// Initialize camera controller
  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        setState(() => _status = "No cameras available");
        return;
      }

      _controller = CameraController(
        cameras.first,
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );

      _initializeControllerFuture = _controller.initialize();
      
      await _initializeControllerFuture;
      
      if (mounted) {
        setState(() {
          _isInitialized = true;
          _status = "Ready to start vision detection";
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _status = "Camera initialization failed: $e");
      }
    }
  }

  /// Start vision detection
  void _startVision() {
    if (!_isInitialized) return;
    
    _geminiService.startVision(_controller);
    setState(() {
      _status = "Vision active - Point camera at objects";
    });
  }

  /// Stop vision detection
  void _stopVision() {
    _geminiService.stopVision();
    setState(() {
      _status = "Vision stopped";
    });
  }

  /// Capture and analyze single image
  Future<void> _captureOnce() async {
    if (!_isInitialized) return;
    
    setState(() => _status = "Analyzing image...");
    
    final result = await _geminiService.captureAndDescribe(_controller);
    
    if (mounted) {
      setState(() {
        _description = result;
        _status = "Analysis complete";
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _geminiService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Surroundings Detection'),
        backgroundColor: AppTheme.primaryBlue,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isInitialized
          ? Stack(
              children: [
                // Camera preview
                CameraPreview(_controller),
                
                // Status indicator at the top
                Positioned(
                  top: 20,
                  left: 20,
                  right: 20,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _geminiService.isProcessing
                          ? AppTheme.accentYellow.withOpacity(0.9)
                          : _geminiService.isRunning
                              ? AppTheme.primaryBlue.withOpacity(0.9)
                              : Colors.grey.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _status,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),

                // Object description in the center
                if (_description.isNotEmpty)
                  Positioned(
                    top: 100,
                    left: 20,
                    right: 20,
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.black87,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppTheme.accentYellow, width: 2),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            "OBJECT DETECTED:",
                            style: TextStyle(
                              color: AppTheme.accentYellow,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _description,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),

                // Control buttons at the bottom
                Positioned(
                  bottom: 30,
                  left: 20,
                  right: 20,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Processing indicator
                      if (_geminiService.isProcessing)
                        const Padding(
                          padding: EdgeInsets.only(bottom: 16),
                          child: CircularProgressIndicator(
                            color: AppTheme.accentYellow,
                            strokeWidth: 3,
                          ),
                        ),
                      
                      // Main control button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _geminiService.isRunning
                                ? Colors.red
                                : AppTheme.primaryBlue,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: _geminiService.isProcessing
                              ? null
                              : (_geminiService.isRunning ? _stopVision : _startVision),
                          child: Text(
                            _geminiService.isRunning ? "STOP VISION" : "START VISION",
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 12),
                      
                      // Single capture button
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: const BorderSide(color: Colors.white, width: 2),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: _geminiService.isProcessing ? null : _captureOnce,
                          child: const Text(
                            "CAPTURE ONCE",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            )
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(
                    color: AppTheme.primaryBlue,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    _status,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
    );
  }
}
