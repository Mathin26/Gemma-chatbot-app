import 'package:flutter/material.dart';
import 'package:flutter_gemma/flutter_gemma.dart';

import 'screens/chat_screen.dart';
import 'screens/settings_screen.dart';
import 'services/storage_service.dart';

final ValueNotifier<ThemeMode> themeModeNotifier =
    ValueNotifier(ThemeMode.light);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final savedTheme = await StorageService.instance.loadThemeMode();
  themeModeNotifier.value = _mapTheme(savedTheme);

  await FlutterGemma.initialize(
    webStorageMode: WebStorageMode.cacheApi,
  );

  runApp(const GemmaVoiceApp());
}

ThemeMode _mapTheme(String mode) {
  switch (mode) {
    case 'dark':
      return ThemeMode.dark;
    case 'system':
      return ThemeMode.system;
    case 'light':
    default:
      return ThemeMode.light;
  }
}

class GemmaVoiceApp extends StatelessWidget {
  const GemmaVoiceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeModeNotifier,
      builder: (context, mode, _) {
        return MaterialApp(
          title: 'Gemma Chat',
          debugShowCheckedModeBanner: false,
          themeMode: mode,
          theme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.light,
            colorSchemeSeed: Colors.blue,
            scaffoldBackgroundColor: const Color(0xFFF9F7F7),
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFFF9F7F7),
              foregroundColor: Colors.black,
              elevation: 0,
              centerTitle: false,
            ),
            cardTheme: const CardThemeData(
              color: Colors.white,
              elevation: 0,
              margin: EdgeInsets.zero,
            ),
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.dark,
            colorSchemeSeed: Colors.blue,
          ),
          routes: {
            '/': (_) => const ChatScreen(),
            '/settings': (_) => const SettingsScreen(),
          },
          initialRoute: '/',
        );
      },
    );
  }
}