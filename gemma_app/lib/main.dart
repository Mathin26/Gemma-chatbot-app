import 'package:flutter/material.dart';
import 'package:flutter_gemma/flutter_gemma.dart';

import 'screens/chat_screen.dart';
import 'screens/settings_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await FlutterGemma.initialize();

  runApp(const GemmaVoiceApp());
}

class GemmaVoiceApp extends StatelessWidget {
  const GemmaVoiceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gemma Voice AI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.blue,
        brightness: Brightness.dark,
        useMaterial3: true,
      ),
      routes: {
        '/': (_) => const ChatScreen(),
        '/settings': (_) => const SettingsScreen(),
      },
      initialRoute: '/',
    );
  }
}