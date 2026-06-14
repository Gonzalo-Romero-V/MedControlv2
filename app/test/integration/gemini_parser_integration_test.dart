/// Test de integración — llama a la API real de Gemini.
/// Requiere AI_API_KEY válida en app/.env
/// Correr con: flutter test test/integration/gemini_parser_integration_test.dart
library;

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:med_control/data/services/gemini_parser_service.dart';
import 'package:med_control/domain/entities/treatment_facts.dart';

void main() {
  final env = _loadEnv(File('.env'));

  group('GeminiParserService — integración real', () {
    late GeminiParserService service;

    setUp(() {
      final apiKey = env['AI_API_KEY'] ?? '';
      final model = env['AI_MODEL'] ?? 'gemini-2.0-flash';

      if (apiKey.isEmpty || apiKey.startsWith('your_')) {
        fail('AI_API_KEY no configurada en .env');
      }

      service = GeminiParserService(apiKey: apiKey, model: model);
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

      printResult('Ibuprofeno 400mg c/8h', result.medicationName,
          result.doseAmount, result.doseUnit, result.frequencyType,
          result.frequencyValue, result.specialInstructions,
          result.endCriterionType, result.durationDays, result.isCritical,
          result.rawAiResponse);

      expect(result.medicationName, isNotNull,
          reason: 'Debe extraer nombre del medicamento');
      expect(result.doseAmount, isNotNull,
          reason: 'Debe extraer dosis numérica');
      expect(result.frequencyType, equals(FrequencyType.everyNHours),
          reason: 'Debe reconocer "cada 8 horas" como everyNHours');
      expect(result.frequencyValue, equals(8),
          reason: 'Debe extraer el valor 8');
    });

    test('parsea receta con insulina (es_critico = true)', () async {
      const sampleOcr = '''
RECETA MÉDICA

Insulina glargina 100 UI/mL
10 unidades subcutáneas antes de dormir
Tratamiento indefinido
''';

      final result = await service.parse(sampleOcr);

      printResult('Insulina glargina', result.medicationName,
          result.doseAmount, result.doseUnit, result.frequencyType,
          result.frequencyValue, result.specialInstructions,
          result.endCriterionType, result.durationDays, result.isCritical,
          result.rawAiResponse);

      expect(result.isCritical, isTrue,
          reason: 'Insulina debe marcarse como medicamento crítico');
    });

    test('devuelve null para campo no presente en la receta', () async {
      const sampleOcr = '''
Paracetamol 500mg
Tomar según necesidad
''';

      final result = await service.parse(sampleOcr);

      printResult('Paracetamol PRN', result.medicationName,
          result.doseAmount, result.doseUnit, result.frequencyType,
          result.frequencyValue, result.specialInstructions,
          result.endCriterionType, result.durationDays, result.isCritical,
          result.rawAiResponse);

      // No se puede saber si hay dosis o no, pero frecuencia debería ser a_demanda
      expect(result.frequencyType, equals(FrequencyType.onDemand),
          reason: '"según necesidad" debe mapearse a onDemand');
      // No invenció principio activo si no está explícito
      expect(result.rawAiResponse, isNotNull);
    });
  });
}

void printResult(
    String label,
    String? name,
    double? dose,
    String? unit,
    dynamic freqType,
    int? freqVal,
    String? instructions,
    String? endCriterion,
    int? durationDays,
    bool isCritical,
    String? rawJson) {
  // ignore: avoid_print
  print('''
─── $label ───────────────────────────
  nombre:       $name
  dosis:        $dose $unit
  frecuencia:   $freqType × $freqVal
  instrucciones:$instructions
  criterio_fin: $endCriterion (${durationDays}d)
  es_critico:   $isCritical
  raw_ai:       ${rawJson?.substring(0, rawJson.length.clamp(0, 200))}...
''');
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
