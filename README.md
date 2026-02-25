<p align="center">
  <h1 align="center">✨ Lumos</h1>
  <p align="center"><em>Illuminating the world, through sound.</em></p>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/React_Native-0.73-61DAFB?style=flat-square&logo=react" alt="React Native" />
  <img src="https://img.shields.io/badge/TypeScript-5.0-3178C6?style=flat-square&logo=typescript" alt="TypeScript" />
  <img src="https://img.shields.io/badge/Gemini_API-Vision-4285F4?style=flat-square&logo=google" alt="Gemini" />
  <img src="https://img.shields.io/badge/TFLite-On--device_AI-FF6F00?style=flat-square&logo=tensorflow" alt="TFLite" />
  <img src="https://img.shields.io/badge/License-MIT-green?style=flat-square" alt="License" />
</p>

---

**Lumos** is a React Native mobile application that serves as an intelligent vision assistant for visually impaired users. It uses AI-powered image recognition to describe the user's surroundings through audio feedback — working both **online** (via Google's Gemini Vision API) and **offline** (via on-device TFLite object detection).

## 🎯 Key Features

| Feature | Description |
|---------|-------------|
| 🌐 **Online Scene Description** | Captures a photo and sends it to the Gemini Vision API for a detailed, natural-language description spoken aloud via TTS. |
| 📴 **Offline Object Detection** | Uses an on-device SSD MobileNet v2 TFLite model to detect common objects (cars, people, bicycles, etc.) when the device has no internet. |
| 🔀 **Smart AI Switch** | Automatically detects connectivity and routes to the best available AI — seamless for the user. |
| 🗣️ **Text-to-Speech** | All descriptions and detections are spoken aloud using `react-native-tts`, supporting English, Hindi, and Kannada. |
| 🌍 **Multilingual Support** | Full i18n support with translations in **English**, **Hindi** (हिन्दी), and **Kannada** (ಕನ್ನಡ). Language preference is persisted across sessions. |
| 📳 **Haptic Feedback** | Vibration pulse on every interaction to acknowledge user input. |

## 📁 Project Structure

```
Lumos/
├── App.tsx                         # Root component — UI, language switching, describe button
├── index.js                        # React Native entry point
├── package.json                    # Dependencies and scripts
├── app.json                        # App configuration
│
├── src/
│   ├── ai/
│   │   ├── smartSwitch.ts          # Connectivity-aware AI router (online vs offline)
│   │   └── onlineDescriber.ts      # Gemini Vision API client
│   │
│   ├── components/
│   │   ├── ObjectDetector.tsx       # Real-time TFLite object detection with camera
│   │   └── CameraView.tsx          # Reusable camera view component
│   │
│   ├── screens/
│   │   └── CameraScreen.tsx        # Standalone camera screen
│   │
│   ├── i18n/
│   │   ├── i18n.ts                 # i18next initialization and language persistence
│   │   ├── LanguageSelector.tsx     # Language picker UI component
│   │   └── speech.ts              # TTS helper — speaks translated strings
│   │
│   └── translations/
│       ├── en.json                 # English translations
│       ├── hi.json                 # Hindi translations
│       └── kn.json                 # Kannada translations
│
├── assets/
│   ├── ssd_mobilenet_v2.tflite    # On-device object detection model
│   └── ssd_mobilenet_v2.txt       # Label map for the TFLite model
│
├── server/                         # Backend API proxy
│   ├── index.js                    # Express server — proxies requests to Gemini API
│   ├── package.json                # Server dependencies
│   └── .env.example                # Server environment template
│
├── android/                        # Android native project
├── ios/                            # iOS native project
│
├── .env.example                    # Environment variable template
├── babel.config.js                 # Babel config (includes reanimated plugin)
├── metro.config.js                 # Metro bundler config (tflite asset support)
├── tsconfig.json                   # TypeScript configuration
├── jest.config.js                  # Test configuration
├── .eslintrc.js                    # ESLint configuration
├── .prettierrc.js                  # Prettier configuration
└── Gemfile                         # Ruby dependencies for iOS CocoaPods
```

## 🏗️ Architecture

```
┌──────────────────────────────────────┐
│              App.tsx                 │
│   (UI, language switch, describe)    │
└────────────┬─────────────────────────┘
             │
             ▼
┌──────────────────────────────────────┐
│         smartSwitch.ts               │
│   Checks connectivity → routes to:  │
├──────────────────┬───────────────────┤
│   🌐 ONLINE      │   📴 OFFLINE      │
│                  │                   │
│ onlineDescriber  │ ObjectDetector    │
│ (Gemini API)     │ (TFLite on-device)│
└──────────────────┴───────────────────┘
             │
             ▼
┌──────────────────────────────────────┐
│         speech.ts / TTS              │
│   Speaks result in selected language │
└──────────────────────────────────────┘
```

## 🚀 Getting Started

### Prerequisites

- **Node.js** ≥ 18
- **React Native CLI** development environment ([Setup Guide](https://reactnative.dev/docs/environment-setup))
- **Android Studio** (for Android) or **Xcode** (for iOS)
- A **Gemini API key** from [Google AI Studio](https://aistudio.google.com/apikey)

### 1. Clone & Install

```bash
git clone https://github.com/your-username/Lumos.git
cd Lumos
npm install
```

### 2. Configure Environment Variables

```bash
# Copy the template and fill in your API key
cp .env.example .env
```

Edit `.env`:
```
GEMINI_API_KEY=your_actual_api_key_here
```

### 3. Start the Backend Server (Optional — for online mode)

```bash
cd server
npm install
cp .env.example .env
# Edit server/.env with your Gemini API key
npm start
```

The server runs on `http://0.0.0.0:3000` by default.

### 4. Run the App

**Android:**
```bash
npx react-native run-android
```

**iOS:**
```bash
cd ios && pod install && cd ..
npx react-native run-ios
```

## 🧠 How It Works

### Online Mode (with internet)
1. User taps the **"Tap to Describe"** button
2. The app captures a photo and encodes it as Base64
3. `smartSwitch.ts` detects an internet connection
4. The image is sent to the **Gemini Vision API** via `onlineDescriber.ts`
5. Gemini returns a natural-language description
6. The description is spoken aloud via TTS in the selected language

### Offline Mode (no internet)
1. User taps the **"Tap to Describe"** button
2. `smartSwitch.ts` detects no internet connection
3. The on-device **SSD MobileNet v2** TFLite model runs object detection
4. Detected objects are counted and synthesized into a sentence (e.g., *"I see 2 cars and 1 person"*)
5. The synthesized description is spoken aloud via TTS

## 🌍 Supported Languages

| Language | Code | TTS Voice |
|----------|------|-----------|
| English  | `en` | `en-US`   |
| Hindi    | `hi` | `hi-IN`   |
| Kannada  | `kn` | `kn-IN`   |

Language preference is automatically saved to device storage and restored on next launch.

## 📦 Dependencies

### Mobile App
| Package | Purpose |
|---------|---------|
| `react-native-vision-camera` | Camera access and frame processing |
| `react-native-fast-tflite` | On-device TFLite model inference |
| `react-native-reanimated` | Worklet-based frame processor support |
| `react-native-tts` | Text-to-speech output |
| `react-native-config` | Environment variable management |
| `@react-native-community/netinfo` | Network connectivity detection |
| `i18next` / `react-i18next` | Internationalization framework |
| `@react-native-async-storage/async-storage` | Persistent language preference |
| `react-native-safe-area-context` | Safe area insets |

### Backend Server
| Package | Purpose |
|---------|---------|
| `express` | HTTP server |
| `axios` | Gemini API requests |
| `cors` | Cross-origin support |
| `dotenv` | Environment variable loading |
| `body-parser` | JSON request parsing |

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Guidelines
- Maintain accessibility as the top priority
- Test with screen readers and accessibility tools
- Provide both voice and manual controls for any new feature
- Add translations for all three supported languages
- Keep the interface clean and high-contrast

## 📄 License

This project is licensed under the MIT License — see the [LICENSE](LICENSE) file for details.

---

<p align="center">
  <strong>Built with ❤️ for accessibility</strong><br/>
  <em>Making the world visible through sound</em>
</p>
