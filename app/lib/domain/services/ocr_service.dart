import 'dart:io';

/// Interfaz de extracción de texto desde imagen.
/// Implementaciones: CloudVisionOcrService (online), MlKitOcrService (offline).
abstract class OcrService {
  Future<String> extractText(File imageFile);
}
