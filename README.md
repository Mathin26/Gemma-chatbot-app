# Gemma Offline Chat App

A Flutter mobile app for running a local Gemma-powered chatbot with speech input, speech output, chat history, and a settings screen.

## Features

### Version 1.0
- Local on-device Gemma chat
- Local model selection from device storage
- Speech-to-text (ASR) input
- Text-to-speech (TTS) output
- Persistent chat history
- Settings screen with theme selection
- Light mode by default, with optional dark mode

## Project structure

```text
lib/
├── main.dart
├── models/
│   └── chat_message.dart
├── screens/
│   ├── chat_screen.dart
│   └── settings_screen.dart
├── services/
│   ├── gemma_service.dart
│   ├── speech_service.dart
│   ├── storage_service.dart
│   └── tts_service.dart
└── widgets/
    ├── chat_input.dart
    └── message_bubble.dart
```

## Tech stack

- Flutter
- `flutter_gemma`
- `speech_to_text`
- `flutter_tts`
- `file_picker`
- `shared_preferences`

The current `pubspec.yaml` already includes these dependencies for local chat, speech features, file picking, and storage.[cite:5]

## Model support

This project is currently aligned with the `flutter_gemma` package flow rather than a direct GGUF runtime. The package documentation and current package page emphasize initialization through `FlutterGemma.initialize(...)`, active model loading through the package API, and deployment formats such as `.task`, `.litertlm`, `.bin`, and `.tflite`.[cite:6]

If strict GGUF support is required, the inference backend should be replaced with a GGUF-native mobile runtime rather than relying on `flutter_gemma`.[cite:6]

## Setup

### 1. Clone and open the project

```bash
git clone <your-repo-url>
cd gemma_app
```

### 2. Get dependencies

```bash
flutter pub get
```

### 3. Enable Windows Developer Mode if needed

On Windows, Flutter plugin builds may require symlink support, and Flutter suggests enabling Developer Mode when that support is missing.[cite:53]

```powershell
start ms-settings:developers
```

### 4. Android configuration

Add microphone permission in:

```text
android/app/src/main/AndroidManifest.xml
```

```xml
<uses-permission android:name="android.permission.RECORD_AUDIO" />
```

For release builds, custom ProGuard or R8 rules are often stored in `android/app/proguard-rules.pro`, and Flutter Android projects commonly wire that file in the app-level Gradle config.[cite:36][cite:40]

### 5. Run the app

```bash
flutter run
```

### 6. Build release APK

```bash
flutter build apk --release
```

## Android release notes

The project hit an R8 release-build failure caused by missing MediaPipe-related classes during minification, which is the kind of issue typically fixed by adding keep rules to `proguard-rules.pro` and, when generated, copying additional rules from `build/app/outputs/mapping/release/missing_rules.txt`.[cite:31][cite:6]

A later Android build failure came from inconsistent Java and Kotlin JVM targets, where Java compiled for 11 while Kotlin compiled for 17. The fix is to align both Java and Kotlin to the same target, commonly Java 17, in the Android Gradle configuration.[cite:50][cite:58]

## Manual cleanup if `flutter clean` fails

Flutter documents `flutter clean` as removing the `build/` and `.dart_tool/` directories.[cite:83] When Windows locks files and cleanup fails, the most common manual cleanup targets are:

- `build/`
- `.dart_tool/`
- `android/.gradle/`
- `android/app/build/`
- `.flutter-plugins-dependencies`

Manual cache cleanup guidance for Flutter projects commonly includes those generated directories because they are recreated by Flutter and Gradle on the next build.[cite:81][cite:85]

## How to use

1. Launch the app.
2. Open **Settings**.
3. Select a supported local model file.
4. Load the model.
5. Return to chat and send a message by typing or speaking.
6. Use the TTS toggle to enable or disable spoken responses.

The app architecture already includes a chat screen, settings screen, speech service, Gemma service, and shared-preferences-backed storage, which supports this Version 1 workflow cleanly.[cite:4][cite:3][cite:2][cite:1][cite:5]

## UI notes

The chat UI was redesigned toward a cleaner mobile layout inspired by the provided reference image, with a light-first theme, compact blue user bubbles, wider assistant message cards, and a simplified bottom composer.[cite:5]

## Known limitations

- Current `flutter_gemma` integration is best matched to supported package model formats rather than direct GGUF-only workflows.[cite:6]
- Release Android builds may still need extra R8 keep rules depending on plugin and dependency resolution state.[cite:31][cite:6]
- Midrange mobile devices should start with smaller Gemma variants for realistic on-device performance.[cite:96][cite:99]

## Recommended models

For smaller mobile hardware, a compact Gemma-family model is the safer starting point than larger 4B or 9B variants. Current listings surfaced a practical GGUF option in Gemma 2 2B IT Q4_K_M and LiteRT-aligned options such as Gemma 3n E2B for `flutter_gemma`-style runtimes.[cite:96][cite:97][cite:99][cite:103]

## License

Apache-2.0 license
