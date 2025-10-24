import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';
import '../theme/app_theme.dart';
import '../services/flashlight_service.dart';

/// Flashlight page with voice control functionality
/// Allows users to control flashlight using voice commands
class FlashlightPage extends StatefulWidget {
  const FlashlightPage({super.key});

  @override
  State<FlashlightPage> createState() => _FlashlightPageState();
}

class _FlashlightPageState extends State<FlashlightPage> {
  final FlashlightService _flashlightService = FlashlightService();
  final SpeechToText _speechToText = SpeechToText();
  
  bool _isListening = false;
  bool _hasPermission = false;
  String _lastCommand = "";
  String _status = "Initializing...";

  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  /// Initialize flashlight and speech services
  Future<void> _initializeServices() async {
    await _flashlightService.initialize();
    
    // Request permissions
    final hasCameraPermission = await _flashlightService.requestPermission();
    final hasSpeechPermission = await _speechToText.initialize();
    
    setState(() {
      _hasPermission = hasCameraPermission && hasSpeechPermission;
      _status = _hasPermission 
          ? "Ready - Say 'turn on', 'turn off', or 'toggle'"
          : "Permissions required";
    });
  }

  /// Start listening for voice commands
  Future<void> _startListening() async {
    if (!_hasPermission || _isListening) return;

    setState(() {
      _isListening = true;
      _status = "Listening... Say a command";
    });

    await _speechToText.listen(
      onResult: (result) {
        setState(() {
          _lastCommand = result.recognizedWords;
        });
        
        if (result.finalResult) {
          _processCommand(result.recognizedWords);
        }
      },
      listenFor: const Duration(seconds: 5),
      pauseFor: const Duration(seconds: 2),
      partialResults: true,
      localeId: "en_US",
      onSoundLevelChange: (level) {
        // Optional: Add visual feedback for sound level
      },
    );
  }

  /// Stop listening for voice commands
  Future<void> _stopListening() async {
    await _speechToText.stop();
    setState(() {
      _isListening = false;
      _status = "Stopped listening";
    });
  }

  /// Process voice command
  Future<void> _processCommand(String command) async {
    setState(() {
      _status = "Processing: $command";
    });

    await _flashlightService.processVoiceCommand(command);
    
    setState(() {
      _status = "Ready - Say 'turn on', 'turn off', or 'toggle'";
    });
  }

  /// Manual toggle flashlight
  Future<void> _toggleFlashlight() async {
    await _flashlightService.toggleFlashlight();
    setState(() {});
  }

  @override
  void dispose() {
    _flashlightService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundWhite,
      appBar: AppBar(
        title: const Text('Voice Flashlight'),
        backgroundColor: AppTheme.primaryBlue,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Status indicator
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _isListening
                      ? AppTheme.accentYellow.withOpacity(0.1)
                      : _flashlightService.isOn
                          ? AppTheme.primaryBlue.withOpacity(0.1)
                          : Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _isListening
                        ? AppTheme.accentYellow
                        : _flashlightService.isOn
                            ? AppTheme.primaryBlue
                            : Colors.grey,
                    width: 2,
                  ),
                ),
                child: Text(
                  _status,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: _isListening
                        ? AppTheme.accentYellow
                        : _flashlightService.isOn
                            ? AppTheme.primaryBlue
                            : AppTheme.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              
              const SizedBox(height: 40),
              
              // Flashlight visual indicator
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Flashlight icon
                      Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          color: _flashlightService.isOn
                              ? AppTheme.accentYellow
                              : Colors.grey.withOpacity(0.3),
                          shape: BoxShape.circle,
                          boxShadow: _flashlightService.isOn
                              ? [
                                  BoxShadow(
                                    color: AppTheme.accentYellow.withOpacity(0.5),
                                    blurRadius: 30,
                                    spreadRadius: 10,
                                  ),
                                ]
                              : null,
                        ),
                        child: Icon(
                          Icons.flashlight_on,
                          size: 100,
                          color: _flashlightService.isOn
                              ? Colors.white
                              : Colors.grey,
                        ),
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // Flashlight status text
                      Text(
                        _flashlightService.isOn ? "ON" : "OFF",
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: _flashlightService.isOn
                              ? AppTheme.accentYellow
                              : AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              // Voice command display
              if (_lastCommand.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        "Last Command:",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _lastCommand,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primaryBlue,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              
              // Control buttons
              Column(
                children: [
                  // Voice control button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isListening
                            ? Colors.red
                            : AppTheme.primaryBlue,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: _hasPermission
                          ? (_isListening ? _stopListening : _startListening)
                          : null,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _isListening ? Icons.mic : Icons.mic_none,
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            _isListening ? "STOP LISTENING" : "START VOICE CONTROL",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Manual toggle button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.primaryBlue,
                        side: const BorderSide(color: AppTheme.primaryBlue, width: 2),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: _hasPermission ? _toggleFlashlight : null,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _flashlightService.isOn
                                ? Icons.flashlight_off
                                : Icons.flashlight_on,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _flashlightService.isOn ? "TURN OFF" : "TURN ON",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 20),
              
              // Voice commands help
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.backgroundWhite,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.textSecondary.withOpacity(0.3)),
                ),
                child: Column(
                  children: [
                    const Text(
                      "Voice Commands:",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textDark,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "• 'Turn on' or 'On'\n• 'Turn off' or 'Off'\n• 'Toggle' or 'Switch'",
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
