import 'dart:io';

import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

import '../../domain/services/ocr_service.dart';

/// OCR offline usando Google ML Kit Text Recognition (on-device, sin internet).
/// Fallback de Ruta 2 cuando no hay conectividad o no hay VISION_API_KEY.
class MlKitOcrService implements OcrService {
  final TextRecognizer _recognizer =
      TextRecognizer(script: TextRecognitionScript.latin);

  @override
  Future<String> extractText(File imageFile) async {
    final inputImage = InputImage.fromFilePath(imageFile.path);
    final result = await _recognizer.processImage(inputImage);
    return result.text;
  }

  void dispose() => _recognizer.close();
}
