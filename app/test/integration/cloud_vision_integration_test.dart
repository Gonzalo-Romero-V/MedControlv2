/// Test de integración — Cloud Vision con service account JSON.
/// Verifica autenticación OAuth2 y llamada real a la API.
/// Usa la imagen del launcher (sin texto útil) solo para confirmar que el pipeline funciona.
/// Correr con: flutter test test/integration/cloud_vision_integration_test.dart
library;

import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:googleapis_auth/auth_io.dart';

void main() {
  final env = _loadEnv(File('.env'));

  group('Cloud Vision — autenticación + integración real', () {
    test('service account JSON es válido y obtiene access token', () async {
      final credPath = env['VISION_CREDENTIALS_PATH'] ?? '';
      if (credPath.isEmpty || credPath.startsWith('your_')) {
        fail('VISION_CREDENTIALS_PATH no configurada en .env');
      }

      final credFile = File(credPath);
      if (!credFile.existsSync()) {
        fail('Archivo de credenciales no encontrado: $credPath');
      }

      final credentialsJson = credFile.readAsStringSync();
      final credentials = ServiceAccountCredentials.fromJson(credentialsJson);

      // Obtener cliente autenticado — confirma que el JSON y la key privada son válidos
      final authClient = await clientViaServiceAccount(
        credentials,
        ['https://www.googleapis.com/auth/cloud-vision'],
      );

      // ignore: avoid_print
      print('✅ Service account autenticado: ${credentials.email}');

      authClient.close();
    });

    test('llamada real a Cloud Vision con imagen de prueba', () async {
      final credPath = env['VISION_CREDENTIALS_PATH'] ?? '';
      if (credPath.isEmpty || credPath.startsWith('your_')) {
        fail('VISION_CREDENTIALS_PATH no configurada en .env');
      }

      final credFile = File(credPath);
      if (!credFile.existsSync()) {
        fail('Archivo de credenciales no encontrado: $credPath');
      }

      // Imagen de prueba: launcher icon de Android (sin texto útil,
      // pero confirma que el pipeline auth → API funciona sin errores)
      final testImage = File(
        'android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png',
      );
      if (!testImage.existsSync()) {
        fail('Imagen de prueba no encontrada: ${testImage.path}');
      }

      final credentialsJson = credFile.readAsStringSync();
      final credentials = ServiceAccountCredentials.fromJson(credentialsJson);
      final authClient = await clientViaServiceAccount(
        credentials,
        ['https://www.googleapis.com/auth/cloud-vision'],
      );

      try {
        final bytes = await testImage.readAsBytes();
        final base64Image = base64Encode(bytes);

        final response = await authClient.post(
          Uri.parse('https://vision.googleapis.com/v1/images:annotate'),
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

        // ignore: avoid_print
        print('HTTP status: ${response.statusCode}');

        // Solo verificamos que la API responde sin error — el launcher no tiene texto
        expect(response.statusCode, equals(200),
            reason: 'Cloud Vision debe responder 200 OK');

        final json = jsonDecode(response.body) as Map<String, dynamic>;
        final text = json['responses']?[0]?['fullTextAnnotation']?['text'];

        // ignore: avoid_print
        print('Texto detectado: ${text ?? "(ninguno — imagen sin texto)"}');
        // ignore: avoid_print
        print('✅ Pipeline Cloud Vision funciona correctamente');
      } finally {
        authClient.close();
      }
    });
  });
}

Map<String, String> _loadEnv(File file) {
  if (!file.existsSync()) return {};
  final env = <String, String>{};
  for (final line in file.readAsLinesSync()) {
    final t = line.trim();
    if (t.isEmpty || t.startsWith('#')) continue;
    final idx = t.indexOf('=');
    if (idx == -1) continue;
    env[t.substring(0, idx).trim()] = t.substring(idx + 1).trim();
  }
  return env;
}
