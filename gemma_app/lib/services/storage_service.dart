import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/chat_message.dart';

class StorageService {
  StorageService._();

  static final StorageService instance = StorageService._();

  static const String _chatHistoryKey = 'chat_history';
  static const String _ttsEnabledKey = 'tts_enabled';
  static const String _selectedModelPathKey = 'selected_model_path';
  static const String _speechLocaleKey = 'speech_locale';

  Future<void> saveMessages(List<ChatMessage> messages) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = messages.map((m) => jsonEncode(m.toJson())).toList();
    await prefs.setStringList(_chatHistoryKey, encoded);
  }

  Future<List<ChatMessage>> loadMessages() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getStringList(_chatHistoryKey) ?? [];

    return stored
        .map((item) {
          try {
            final map = jsonDecode(item) as Map<String, dynamic>;
            return ChatMessage.fromJson(map);
          } catch (_) {
            return null;
          }
        })
        .whereType<ChatMessage>()
        .toList();
  }

  Future<void> clearMessages() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_chatHistoryKey);
  }

  Future<void> saveTtsEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_ttsEnabledKey, enabled);
  }

  Future<bool> loadTtsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_ttsEnabledKey) ?? true;
  }

  Future<void> saveSelectedModelPath(String path) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_selectedModelPathKey, path);
  }

  Future<String> loadSelectedModelPath() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_selectedModelPathKey) ?? '';
  }

  Future<void> saveSpeechLocale(String localeId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_speechLocaleKey, localeId);
  }

  Future<String?> loadSpeechLocale() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_speechLocaleKey);
  }
}