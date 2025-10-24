# Lumos - Intelligent Vision Assistant

A minimalist Flutter app designed for accessibility, featuring AI-powered surroundings detection and voice-controlled flashlight functionality.

## Features

### 🏠 Home Page
- Clean, minimalist design with Material 3 theming
- Prominent Start button for easy navigation
- White-blue-yellow color palette for accessibility

### 🔍 Surroundings Detection
- AI-powered object recognition using Gemini API
- Real-time camera feed with object descriptions
- Text-to-speech feedback for detected objects
- Continuous or single-capture modes

### 🔦 Voice-Controlled Flashlight
- Hands-free flashlight control using voice commands
- Speech recognition for "turn on", "turn off", and "toggle" commands
- Visual feedback with animated flashlight icon
- Manual toggle option as backup

## Architecture

The app follows a modular architecture with clear separation of concerns:

```
lib/
├── main.dart                 # App entry point
├── theme/
│   └── app_theme.dart       # Material 3 theme configuration
├── services/
│   ├── gemini_service.dart  # AI vision detection service
│   └── flashlight_service.dart # Flashlight control service
├── pages/
│   ├── home_page.dart       # Home screen with Start button
│   ├── features_page.dart   # Feature selection page
│   ├── gemini_vision_page.dart # AI vision detection page
│   └── flashlight_page.dart # Voice-controlled flashlight page
└── widgets/
    └── feature_card.dart    # Reusable feature card component
```

## Dependencies

- `camera`: Camera access for vision detection
- `flutter_tts`: Text-to-speech functionality
- `http`: API communication with Gemini service
- `speech_to_text`: Voice command recognition
- `torch_light`: Flashlight control
- `permission_handler`: Permission management

## Setup

1. Install dependencies:
   ```bash
   flutter pub get
   ```

2. Configure Gemini API server:
   - Update the server URL in `lib/services/gemini_service.dart`
   - Ensure your Gemini API server is running and accessible

3. Run the app:
   ```bash
   flutter run
   ```

## Usage

1. **Start**: Tap the Start button on the home screen
2. **Choose Feature**: Select between Surroundings Detection or Voice Flashlight
3. **Surroundings Detection**: 
   - Point camera at objects
   - Tap "START VISION" for continuous detection
   - Tap "CAPTURE ONCE" for single analysis
4. **Voice Flashlight**:
   - Tap "START VOICE CONTROL" to begin listening
   - Say "turn on", "turn off", or "toggle"
   - Use manual toggle as backup

## Design Principles

- **Accessibility First**: High contrast colors, large touch targets, clear typography
- **Minimalist**: Clean interface with essential features only
- **Modular**: Well-organized code with reusable components
- **Material 3**: Modern design system with consistent theming
- **Voice-First**: Hands-free operation where possible

## Color Palette

- **Primary Blue**: `#1976D2` - Main brand color
- **Light Blue**: `#64B5F6` - Accent color
- **Accent Yellow**: `#FFD54F` - Highlight color
- **Background White**: `#FAFAFA` - Background
- **Surface White**: `#FFFFFF` - Card surfaces
- **Text Dark**: `#212121` - Primary text
- **Text Secondary**: `#757575` - Secondary text

## Contributing

This app is designed for accessibility and should maintain its minimalist approach. When adding features:

1. Keep the interface clean and uncluttered
2. Ensure high contrast and readable text
3. Provide both voice and manual controls
4. Test with accessibility tools
5. Follow Material 3 design guidelines