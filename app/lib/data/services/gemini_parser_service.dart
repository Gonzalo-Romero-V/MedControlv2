import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../domain/entities/parsed_prescription.dart';
import '../../domain/entities/treatment_facts.dart';
import '../../domain/services/ai_parser_service.dart';
import 'prescription_prompt.dart';

/// Parser semántico de recetas usando Google Gemini (REST API).
/// Requiere AI_API_KEY de Google AI Studio o Google Cloud.
class GeminiParserService implements AiParserService {
  final String apiKey;
  final String model;

  static const String _baseUrl =
      'https://generativelanguage.googleapis.com/v1beta/models';

  const GeminiParserService({
    required this.apiKey,
    this.model = 'gemini-2.0-flash',
  });

  @override
  Future<ParsedPrescription> parse(String ocrText) async {
    final prompt = _buildPrompt(ocrText);

    final body = jsonEncode({
      'contents': [
        {
          'parts': [
            {'text': prompt}
          ]
        }
      ],
      'generationConfig': {
        'temperature': 0,
        'responseMimeType': 'application/json',
      },
    });

    final response = await http
        .post(
          Uri.parse('$_baseUrl/$model:generateContent?key=$apiKey'),
          headers: {'Content-Type': 'application/json'},
          body: body,
        )
        .timeout(const Duration(seconds: 30));

    if (response.statusCode != 200) {
      throw Exception('Gemini error ${response.statusCode}: ${response.body}');
    }

    final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
    final candidates = jsonResponse['candidates'] as List<dynamic>;
    if (candidates.isEmpty) throw Exception('Gemini: sin candidatos en respuesta');

    final rawJson = (candidates.first as Map<String, dynamic>)['content']
        ['parts'][0]['text'] as String;

    return _parsePrescriptionFromJson(rawJson, ocrText);
  }

  ParsedPrescription _parsePrescriptionFromJson(
      String rawJson, String ocrText) {
    final Map<String, dynamic> data;
    try {
      data = jsonDecode(rawJson) as Map<String, dynamic>;
    } catch (_) {
      throw Exception('Gemini: respuesta no es JSON válido: $rawJson');
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

  String _buildPrompt(String ocrText) => PrescriptionPrompt.build(ocrText);

  // ─── Helpers de conversión ────────────────────────────────────────────────

  double? _toDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  int? _toInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.round();
    if (value is String) return int.tryParse(value);
    return null;
  }

  FrequencyType? _toFrequencyType(String? value) {
    switch (value) {
      case 'cada_n_horas':
        return FrequencyType.everyNHours;
      case 'n_veces_dia':
        return FrequencyType.nTimesDay;
      case 'a_demanda':
        return FrequencyType.onDemand;
      case 'pauta_reduccion':
        return FrequencyType.tapering;
      default:
        return null;
    }
  }
}
