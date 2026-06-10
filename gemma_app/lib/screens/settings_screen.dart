import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../services/gemma_service.dart';
import '../services/speech_service.dart';
import '../services/storage_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _modelPath = '';
  bool _isLoading = false;
  bool _modelLoaded = false;
  bool _autoTts = true;
  String? _selectedLocaleId;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final savedModelPath = await StorageService.instance.loadSelectedModelPath();
    final ttsEnabled = await StorageService.instance.loadTtsEnabled();
    final localeId = await StorageService.instance.loadSpeechLocale();

    if (!mounted) return;

    setState(() {
      _modelLoaded = GemmaService.instance.isModelLoaded;
      _modelPath = GemmaService.instance.currentModelPath.isNotEmpty
          ? GemmaService.instance.currentModelPath
          : savedModelPath;
      _autoTts = ttsEnabled;
      _selectedLocaleId = localeId;
    });
  }

  Future<void> _pickModel() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: false,
        type: FileType.custom,
        allowedExtensions: ['gguf'],
      );

      if (result == null) return;

      final path = result.files.single.path;
      if (path == null || path.isEmpty) return;

      await StorageService.instance.saveSelectedModelPath(path);

      if (!mounted) return;

      setState(() {
        _modelPath = path;
      });
    } catch (e) {
      _showMessage('Error selecting file: $e');
    }
  }

  Future<void> _loadModel() async {
    if (_modelPath.isEmpty) {
      _showMessage('Please select a GGUF model first.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final success = await GemmaService.instance.loadModel(_modelPath);

      if (!mounted) return;

      if (success) {
        _showMessage('Model loaded successfully.');
      } else {
        _showMessage('Failed to load model.');
      }

      setState(() {
        _modelLoaded = GemmaService.instance.isModelLoaded;
        _modelPath = GemmaService.instance.currentModelPath.isNotEmpty
            ? GemmaService.instance.currentModelPath
            : _modelPath;
      });
    } catch (e) {
      _showMessage('Error loading model: $e');
    } finally {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _unloadModel() async {
    try {
      await GemmaService.instance.unloadModel();

      if (!mounted) return;

      setState(() {
        _modelLoaded = false;
      });

      _showMessage('Model unloaded.');
    } catch (e) {
      _showMessage('Error unloading model: $e');
    }
  }

  Future<void> _toggleTts(bool value) async {
    await StorageService.instance.saveTtsEnabled(value);
    if (!mounted) return;

    setState(() {
      _autoTts = value;
    });
  }

  Future<void> _pickSpeechLocale() async {
    final locales = await SpeechService.instance.getLocales();
    if (!mounted) return;

    await showModalBottomSheet<void>(
      context: context,
      builder: (context) {
        return ListView.separated(
          itemCount: locales.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final locale = locales[index];
            final isSelected = locale.localeId == _selectedLocaleId;

            return ListTile(
              title: Text(locale.name),
              subtitle: Text(locale.localeId),
              trailing: isSelected ? const Icon(Icons.check) : null,
              onTap: () async {
                await StorageService.instance.saveSpeechLocale(locale.localeId);
                if (!mounted) return;

                setState(() {
                  _selectedLocaleId = locale.localeId;
                });

                Navigator.pop(context);
              },
            );
          },
        );
      },
    );
  }

  Future<void> _clearChatHistory() async {
    await StorageService.instance.clearMessages();
    if (!mounted) return;
    _showMessage('Chat history cleared.');
  }

  void _showMessage(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text)),
    );
  }

  Widget _buildModelSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Gemma Model',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Icon(
                  _modelLoaded ? Icons.check_circle : Icons.error_outline,
                  color: _modelLoaded ? Colors.green : Colors.orange,
                ),
                const SizedBox(width: 8),
                Text(_modelLoaded ? 'Status: Loaded' : 'Status: Not Loaded'),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              _modelPath.isEmpty ? 'No model selected' : _modelPath,
              style: const TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _pickModel,
              icon: const Icon(Icons.folder_open),
              label: const Text('Select GGUF Model'),
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _loadModel,
              icon: const Icon(Icons.play_arrow),
              label: Text(_isLoading ? 'Loading...' : 'Load Model'),
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: _modelLoaded ? _unloadModel : null,
              icon: const Icon(Icons.stop),
              label: const Text('Unload Model'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVoiceSection() {
    return Card(
      child: Column(
        children: [
          SwitchListTile(
            title: const Text('Auto Speak Responses'),
            subtitle: const Text('Enable text-to-speech for Gemma replies'),
            value: _autoTts,
            onChanged: _toggleTts,
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.language),
            title: const Text('Speech Recognition Locale'),
            subtitle: Text(_selectedLocaleId ?? 'Use device default'),
            trailing: const Icon(Icons.chevron_right),
            onTap: _pickSpeechLocale,
          ),
        ],
      ),
    );
  }

  Widget _buildHistorySection() {
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.delete_outline),
            title: const Text('Clear Chat History'),
            subtitle: const Text('Removes saved local conversation history'),
            onTap: _clearChatHistory,
          ),
        ],
      ),
    );
  }

  Widget _buildRoadmapSection() {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Planned Roadmap',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text('V2.0 - Memory System'),
            Text('V3.0 - JSON Knowledge Base'),
            Text('V4.0 - BM25 Retrieval'),
            Text('V5.0 - Document Upload'),
            Text('V6.0 - LoRA Support, Agent Tools, Vision'),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildModelSection(),
          const SizedBox(height: 16),
          _buildVoiceSection(),
          const SizedBox(height: 16),
          _buildHistorySection(),
          const SizedBox(height: 16),
          _buildRoadmapSection(),
        ],
      ),
    );
  }
}