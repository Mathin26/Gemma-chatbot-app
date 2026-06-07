import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

import '../services/gemma_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() =>
      _SettingsScreenState();
}

class _SettingsScreenState
    extends State<SettingsScreen> {
  String _modelPath = "";

  bool _isLoading = false;

  bool _modelLoaded = false;

  bool _autoTts = true;

  @override
  void initState() {
    super.initState();

    _refreshModelInfo();
  }

  void _refreshModelInfo() {
    setState(() {
      _modelLoaded =
          GemmaService.instance.isModelLoaded;

      _modelPath =
          GemmaService.instance.currentModelPath;
    });
  }

  Future<void> _pickModel() async {
    try {
      final result =
          await FilePicker.platform.pickFiles(
        allowMultiple: false,
        type: FileType.custom,
        allowedExtensions: ['gguf'],
      );

      if (result == null) return;

      final path =
          result.files.single.path;

      if (path == null) return;

      setState(() {
        _modelPath = path;
      });
    } catch (e) {
      _showMessage(
        "Error selecting file: $e",
      );
    }
  }

  Future<void> _loadModel() async {
    if (_modelPath.isEmpty) {
      _showMessage(
        "Please select a GGUF model first",
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final success =
          await GemmaService.instance
              .loadModel(_modelPath);

      if (success) {
        _showMessage(
          "Model loaded successfully",
        );
      } else {
        _showMessage(
          "Failed to load model",
        );
      }

      _refreshModelInfo();
    } catch (e) {
      _showMessage(
        "Error: $e",
      );
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _unloadModel() async {
    try {
      await GemmaService.instance
          .unloadModel();

      _refreshModelInfo();

      _showMessage(
        "Model unloaded",
      );
    } catch (e) {
      _showMessage(
        "Error: $e",
      );
    }
  }

  void _showMessage(String text) {
    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(text),
      ),
    );
  }

  Widget _buildModelSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            const Text(
              "Gemma Model",
              style: TextStyle(
                fontSize: 18,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(height: 16),

            Text(
              _modelLoaded
                  ? "Status: Loaded"
                  : "Status: Not Loaded",
            ),

            const SizedBox(height: 10),

            Text(
              _modelPath.isEmpty
                  ? "No model selected"
                  : _modelPath,
            ),

            const SizedBox(height: 16),

            ElevatedButton.icon(
              onPressed: _pickModel,
              icon: const Icon(
                Icons.folder_open,
              ),
              label: const Text(
                "Select GGUF Model",
              ),
            ),

            const SizedBox(height: 10),

            ElevatedButton.icon(
              onPressed: _isLoading
                  ? null
                  : _loadModel,
              icon: const Icon(
                Icons.play_arrow,
              ),
              label: Text(
                _isLoading
                    ? "Loading..."
                    : "Load Model",
              ),
            ),

            const SizedBox(height: 10),

            ElevatedButton.icon(
              onPressed:
                  _modelLoaded
                      ? _unloadModel
                      : null,
              icon: const Icon(
                Icons.stop,
              ),
              label: const Text(
                "Unload Model",
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTtsSection() {
    return Card(
      child: SwitchListTile(
        title: const Text(
          "Auto Speak Responses",
        ),
        subtitle: const Text(
          "Enable text-to-speech",
        ),
        value: _autoTts,
        onChanged: (value) {
          setState(() {
            _autoTts = value;
          });
        },
      ),
    );
  }

  Widget _buildFutureFeatures() {
    return Card(
      child: Padding(
        padding:
            const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: const [
            Text(
              "Future Features",
              style: TextStyle(
                fontSize: 18,
                fontWeight:
                    FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Text(
              "• Memory System (v2.0)",
            ),
            Text(
              "• JSON Knowledge Base (v3.0)",
            ),
            Text(
              "• BM25 Retrieval (v4.0)",
            ),
            Text(
              "• LoRA Support (v5.0)",
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Settings",
        ),
      ),
      body: ListView(
        padding:
            const EdgeInsets.all(16),
        children: [
          _buildModelSection(),

          const SizedBox(height: 16),

          _buildTtsSection(),

          const SizedBox(height: 16),

          _buildFutureFeatures(),
        ],
      ),
    );
  }
}