import '../models/chat_message.dart';
import '../models/memory_item.dart';
import 'storage_service.dart';

class MemoryService {
  MemoryService._();

  static final MemoryService instance = MemoryService._();

  final List<MemoryItem> _cache = [];

  List<MemoryItem> get items => List.unmodifiable(_cache);

  Future<void> initialize() async {
    _cache
      ..clear()
      ..addAll(await StorageService.instance.loadMemories());
  }

  Future<void> addMemory({
    required String title,
    required String content,
    required String category,
    int importance = 1,
  }) async {
    final now = DateTime.now();
    final item = MemoryItem(
      id: now.microsecondsSinceEpoch.toString(),
      title: title,
      content: content,
      category: category,
      createdAt: now,
      updatedAt: now,
      importance: importance,
    );
    _cache.add(item);
    await StorageService.instance.saveMemories(_cache);
  }

  Future<void> extractMemoryFromMessage(ChatMessage message) async {
    if (!message.isUser) return;

    final text = message.text.trim();
    final lower = text.toLowerCase();

    if (lower.startsWith('my name is ')) {
      await addMemory(
        title: 'User name',
        content: text,
        category: 'profile',
        importance: 5,
      );
    } else if (lower.contains('i like ') || lower.contains('i love ')) {
      await addMemory(
        title: 'User preference',
        content: text,
        category: 'preference',
        importance: 4,
      );
    } else if (lower.contains('i work on ') ||
        lower.contains('i am building ')) {
      await addMemory(
        title: 'User project',
        content: text,
        category: 'project',
        importance: 4,
      );
    } else if (text.length > 25) {
      await addMemory(
        title: 'Conversation note',
        content: text,
        category: 'context',
        importance: 2,
      );
    }
  }

  List<MemoryItem> getRelevantMemories(String query, {int limit = 5}) {
    final q = query.toLowerCase().trim();

    final scored = _cache.map((item) {
      int score = item.importance;
      if (item.title.toLowerCase().contains(q)) score += 6;
      if (item.content.toLowerCase().contains(q)) score += 8;

      final words = q.split(RegExp(r'\s+')).where((e) => e.isNotEmpty);
      for (final word in words) {
        if (item.content.toLowerCase().contains(word)) score += 2;
        if (item.category.toLowerCase().contains(word)) score += 1;
      }

      return MapEntry(item, score);
    }).toList();

    scored.sort((a, b) => b.value.compareTo(a.value));

    return scored
        .where((entry) => entry.value > 1)
        .take(limit)
        .map((entry) => entry.key)
        .toList();
  }

  String buildMemoryContext(String query) {
    final relevant = getRelevantMemories(query);
    if (relevant.isEmpty) return '';

    final buffer = StringBuffer();
    buffer.writeln('Relevant memory about the user and prior context:');
    for (final item in relevant) {
      buffer.writeln('- [${item.category}] ${item.content}');
    }
    return buffer.toString().trim();
  }

  Future<void> clearAll() async {
    _cache.clear();
    await StorageService.instance.clearMemories();
  }
}