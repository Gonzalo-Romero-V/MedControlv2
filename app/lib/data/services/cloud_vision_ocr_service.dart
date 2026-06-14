import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart' show rootBundle;
import 'package:googleapis_auth/auth_io.dart';

import '../../domain/services/ocr_service.dart';

/// OCR online usando Google Cloud Vision API con autenticación por service account.
///
/// Requiere un archivo JSON de service account con Cloud Vision API habilitada.
/// El path del asset se configura vía VISION_CREDENTIALS_PATH en .env.
///
/// Documentación: console.cloud.google.com → APIs & Services → Credentials
///   → Create credentials → Service account → Cloud Vision API
class CloudVisionOcrService implements OcrService {
  final String credentialsAssetPath;

  static const _visionScope =
      'https://www.googleapis.com/auth/cloud-vision';
  static const _endpoint =
      'https://vision.googleapis.com/v1/images:annotate';

  const CloudVisionOcrService(this.credentialsAssetPath);

  @override
  Future<String> extractText(File imageFile) async {
    final credentialsJson = await rootBundle.loadString(credentialsAssetPath);
    final credentials = ServiceAccountCredentials.fromJson(credentialsJson);
    final authClient = await clientViaServiceAccount(
      credentials,
      [_visionScope],
    );

    try {
      final bytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(bytes);

      final response = await authClient.post(
        Uri.parse(_endpoint),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'requests': [
            {
              'image': {'content': base64Image},
              'features': [
                {'type': 'DOCUMENT_TEXT_DETECTION', 'maxResults': 1}
              ],
            }
          ]
        }),
      );

      if (response.statusCode != 200) {
        throw Exception(
          'Cloud Vision error ${response.statusCode}: ${response.body}',
        );
      }

      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final responses = json['responses'] as List<dynamic>;

      if (responses.isEmpty) throw Exception('Cloud Vision: respuesta vacía');

      final text = (responses.first as Map<String, dynamic>)
          ['fullTextAnnotation']?['text'] as String?;

      if (text == null || text.isEmpty) {
        throw Exception('Cloud Vision: no se detectó texto en la imagen');
      }

      return text;
    } finally {
      authClient.close();
    }
  }
}
