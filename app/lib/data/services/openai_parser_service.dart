import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../domain/entities/parsed_prescription.dart';
import '../../domain/entities/treatment_facts.dart';
import '../../domain/services/ai_parser_service.dart';
import 'prescription_prompt.dart';

/// Parser semántico usando OpenAI (gpt-4o / gpt-4o-mini).
/// Misma interfaz que GeminiParserService — intercambiable vía AI_PROVIDER en .env.
class OpenAiParserService implements AiParserService {
  final String apiKey;
  final String model;

  static const String _endpoint = 'https://api.openai.com/v1/chat/completions';

  const OpenAiParserService({
    required this.apiKey,
    this.model = 'gpt-4o-mini',
  });

  @override
  Future<ParsedPrescription> parse(String ocrText) async {
    final body = jsonEncode({
      'model': model,
      'messages': [
        {'role': 'user', 'content': PrescriptionPrompt.build(ocrText)}
      ],
      'response_format': {'type': 'json_object'},
      'temperature': 0,
    });

    final response = await http
        .post(
          Uri.parse(_endpoint),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $apiKey',
          },
          body: body,
        )
        .timeout(const Duration(seconds: 30));

    if (response.statusCode != 200) {
      throw Exception('OpenAI error ${response.statusCode}: ${response.body}');
    }

    final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
    final rawJson =
        jsonResponse['choices'][0]['message']['content'] as String;

    return _parse(rawJson, ocrText);
  }

  ParsedPrescription _parse(String rawJson, String ocrText) {
    final Map<String, dynamic> data;
    try {
      data = jsonDecode(rawJson) as Map<String, dynamic>;
    } catch (_) {
      throw Exception('OpenAI: respuesta no es JSON válido: $rawJson');
    }

    return ParsedPrescription(
      medicationName: data['nombre_medicamento'] as String?,
      activeIngredient: data['principio_activo'] as String?,
      doseAmount: _toDouble(data['dosis_cantidad']),
      doseUnit: data['dosis_unidad'] as String?,
      frequencyType: _toFrequencyType(data['frecuencia_tipo'] as String?),
      frequencyValue: _toInt(data['frecuencia_valor']),
      route: data['via_administracion'] as String?,
      specialInstructions: data['instrucciones_especiales'] as String?,
      endCriterionType: data['criterio_fin_tipo'] as String?,
      durationDays: _toInt(data['duracion_dias']),
      totalDoses: _toInt(data['cantidad_total_dosis']),
      isCritical: data['es_critico'] as bool? ?? false,
      rawOcrText: ocrText,
      rawAiResponse: rawJson,
      source: PrescriptionSource.cloudVisionGemini,
    );
  }

  double? _toDouble(dynamic v) {
    if (v == null) return null;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    if (v is String) return double.tryParse(v);
    return null;
  }

  int? _toInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is double) return v.round();
    if (v is String) return int.tryParse(v);
    return null;
  }

  FrequencyType? _toFrequencyType(String? v) => switch (v) {
        'cada_n_horas' => FrequencyType.everyNHours,
        'n_veces_dia' => FrequencyType.nTimesDay,
        'a_demanda' => FrequencyType.onDemand,
        'pauta_reduccion' => FrequencyType.tapering,
        _ => null,
      };
}
