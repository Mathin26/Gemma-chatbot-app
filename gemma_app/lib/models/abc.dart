import 'package:flutter_gemma/flutter_gemma.dart';

void test() {
  gemma.initialize();
  gemma.loadModel("path/to/model.gguf").then((success) {
    if (success) {
      print("Model loaded successfully!");
      gemma.generateResponse("Hello, Gemma!").then((response) {
        print("Gemma says: $response");
      });
    } else {
      print("Failed to load model.");
    }
  });
  gemma.unloadModel().then((_) {
    print("Model unloaded.");
  });
  gemma.currentModelPath; // Get current model path
  gemma.isModelLoaded; // Check if model is loaded
  gemma.generateResponse("Test prompt").then((response) {
    print("Response: $response");
  });
  gemma.dispose(); // Clean up resources when done
  gemma.initialize(); // Re-initialize if needed
  gemma.loadModel("new/model/path.gguf").then((success) {
    if (success) {
      print("New model loaded successfully!");
    } else {
      print("Failed to load new model.");
    }
  });
  gemma.unloadModel().then((_) {
    print("Model unloaded again.");
  });
  gemma.generateResponse("Another test prompt").then((response) {
    print("Response: $response");
  });
  
}