import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/feature_card.dart';
import 'gemini_vision_page.dart';
import 'flashlight_page.dart';

/// Features page displaying two main functionality cards
/// One for Gemini surroundings detection and one for voice-controlled flashlight
class FeaturesPage extends StatelessWidget {
  const FeaturesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundWhite,
      appBar: AppBar(
        title: const Text('Features'),
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
              // Page title
              Text(
                'Choose a Feature',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: AppTheme.textDark,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 16),
              
              Text(
                'Select an accessibility feature to get started',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 32),
              
              // Gemini Vision Detection Card
              Expanded(
                child: FeatureCard(
                  title: 'Surroundings Detection',
                  subtitle: 'AI-powered object recognition and description',
                  icon: Icons.visibility,
                  iconColor: AppTheme.primaryBlue,
                  gradientColors: [
                    AppTheme.primaryBlue.withOpacity(0.1),
                    AppTheme.lightBlue.withOpacity(0.05),
                  ],
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const GeminiVisionPage(),
                      ),
                    );
                  },
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Voice-Controlled Flashlight Card
              Expanded(
                child: FeatureCard(
                  title: 'Voice Flashlight',
                  subtitle: 'Hands-free flashlight control with voice commands',
                  icon: Icons.flashlight_on,
                  iconColor: AppTheme.accentYellow,
                  gradientColors: [
                    AppTheme.accentYellow.withOpacity(0.1),
                    AppTheme.accentYellow.withOpacity(0.05),
                  ],
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const FlashlightPage(),
                      ),
                    );
                  },
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Back button
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                style: TextButton.styleFrom(
                  foregroundColor: AppTheme.textSecondary,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text('Back to Home'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
