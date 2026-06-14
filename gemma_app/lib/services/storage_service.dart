import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/chat_message.dart';
import '../models/memory_item.dart';

class StorageService {
  StorageService._();

  static final StorageService instance = StorageService._();

  static const _chatHistoryKey = 'chat_history_v2';
  static const _memoryKey = 'memory_items_v2';
  static const _ttsEnabledKey = 'tts_enabled';
  static const _selectedModelPathKey = 'selected_model_path';
  static const _speechLocaleKey = 'speech_locale';
  static const _themeModeKey = 'theme_mode';

  Future<void> saveMessages(List<ChatMessage> messages) async {
    final prefs = await SharedPreferences.getInstance();
    final data = messages.map((e) => jsonEncode(e.toJson())).toList();
    await prefs.setStringList(_chatHistoryKey, data);
  }

  Future<List<ChatMessage>> loadMessages() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList(_chatHistoryKey) ?? [];
    return data
        .map((e) {
          try {
            return ChatMessage.fromJson(jsonDecode(e));
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

  Future<void> saveMemories(List<MemoryItem> items) async {
    final prefs = await SharedPreferences.getInstance();
    final data = items.map((e) => jsonEncode(e.toJson())).toList();
    await prefs.setStringList(_memoryKey, data);
  }

  Future<List<MemoryItem>> loadMemories() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList(_memoryKey) ?? [];
    return data
        .map((e) {
          try {
            return MemoryItem.fromJson(jsonDecode(e));
          } catch (_) {
            return null;
          }
        })
        .whereType<MemoryItem>()
        .toList();
  }

  Future<void> clearMemories() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_memoryKey);
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

  Future<void> saveSpeechLocale(String locale) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_speechLocaleKey, locale);
  }

  Future<String?> loadSpeechLocale() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_speechLocaleKey);
  }

  Future<void> saveThemeMode(String mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeModeKey, mode);
  }

  Future<String> loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_themeModeKey) ?? 'light';
  }
}