/// Test de integración — llama a la API real de OpenAI.
/// Requiere AI_API_KEY (OpenAI) válida en app/.env
/// Correr con: flutter test test/integration/openai_parser_integration_test.dart
library;

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:med_control/data/services/openai_parser_service.dart';
import 'package:med_control/domain/entities/treatment_facts.dart';

void main() {
  final env = _loadEnv(File('.env'));

  group('OpenAiParserService — integración real', () {
    late OpenAiParserService service;

    setUp(() {
      final apiKey = env['AI_API_KEY'] ?? '';
      final model = env['AI_MODEL'] ?? 'gpt-4o-mini';

      if (apiKey.isEmpty || apiKey.startsWith('your_')) {
        fail('AI_API_KEY no configurada en .env');
      }

      service = OpenAiParserService(apiKey: apiKey, model: model);
    });

    test('parsea receta con ibuprofeno cada 8 horas con comida', () async {
      const sampleOcr = '''
RECETA MÉDICA
Médico: Dr. Roberto Silva — MP 12345
Fecha: 14/06/2026

Nombre: Juan García  Edad: 68 años

Medicamento: Ibuprofeno 400 mg
Indicación: 1 tableta cada 8 horas con comida
Duración: 7 días
''';

      final result = await service.parse(sampleOcr);

      // ignore: avoid_print
      print('''
─── Ibuprofeno 400mg c/8h ───────────────────────────
  nombre:       ${result.medicationName}
  dosis:        ${result.doseAmount} ${result.doseUnit}
  frecuencia:   ${result.frequencyType} × ${result.frequencyValue}
  instrucciones:${result.specialInstructions}
  criterio_fin: ${result.endCriterionType} (${result.durationDays}d)
  es_critico:   ${result.isCritical}
  raw_ai:       ${result.rawAiResponse?.substring(0, result.rawAiResponse!.length.clamp(0, 200))}...
''');

      expect(result.medicationName, isNotNull);
      expect(result.doseAmount, isNotNull);
      expect(result.frequencyType, equals(FrequencyType.everyNHours),
          reason: 'Debe reconocer "cada 8 horas" como everyNHours');
      expect(result.frequencyValue, equals(8));
    });

    test('parsea receta con insulina (es_critico = true)', () async {
      const sampleOcr = '''
RECETA MÉDICA

Insulina glargina 100 UI/mL
10 unidades subcutáneas antes de dormir
Tratamiento indefinido
''';

      final result = await service.parse(sampleOcr);

      // ignore: avoid_print
      print('''
─── Insulina glargina ───────────────────────────
  nombre:     ${result.medicationName}
  es_critico: ${result.isCritical}
  raw_ai:     ${result.rawAiResponse?.substring(0, result.rawAiResponse!.length.clamp(0, 200))}...
''');

      expect(result.isCritical, isTrue,
          reason: 'Insulina debe marcarse como medicamento crítico');
    });

    test('devuelve frecuencia a_demanda para "según necesidad"', () async {
      const sampleOcr = '''
Paracetamol 500mg
Tomar según necesidad
''';

      final result = await service.parse(sampleOcr);

      // ignore: avoid_print
      print('''
─── Paracetamol PRN ───────────────────────────
  frecuencia: ${result.frequencyType}
  raw_ai:     ${result.rawAiResponse?.substring(0, result.rawAiResponse!.length.clamp(0, 200))}...
''');

      expect(result.frequencyType, equals(FrequencyType.onDemand));
      expect(result.rawAiResponse, isNotNull);
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
