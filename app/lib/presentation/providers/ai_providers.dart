import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/services/cloud_vision_ocr_service.dart';
import '../../data/services/gemini_parser_service.dart';
import '../../data/services/mlkit_ocr_service.dart';
import '../../data/services/openai_parser_service.dart';
import '../../domain/services/ai_parser_service.dart';
import '../../domain/services/ocr_service.dart';
import '../../domain/use_cases/parse_prescription_use_case.dart';

// ─── Lectura de .env ──────────────────────────────────────────────────────────

String _env(String key, {String fallback = ''}) =>
    dotenv.env[key] ?? fallback;

bool _isSet(String key) {
  final v = _env(key);
  return v.isNotEmpty && v != 'your_api_key_here' && v != 'your_key_here';
}

// ─── Providers de servicios ───────────────────────────────────────────────────

/// Selecciona el AiParserService según AI_PROVIDER en .env.
final aiParserServiceProvider = Provider<AiParserService>((ref) {
  final provider = _env('AI_PROVIDER', fallback: 'gemini');
  final apiKey = _env('AI_API_KEY');
  final model = _env('AI_MODEL');

  return switch (provider) {
    'openai' => OpenAiParserService(
        apiKey: apiKey,
        model: model.isEmpty ? 'gpt-4o-mini' : model,
      ),
    _ => GeminiParserService(
        apiKey: apiKey,
        model: model.isEmpty ? 'gemini-2.0-flash' : model,
      ),
  };
});

/// OCR online — Cloud Vision con service account JSON.
/// El path del asset viene de VISION_CREDENTIALS_PATH en .env.
final cloudOcrServiceProvider = Provider<OcrService>((ref) {
  return CloudVisionOcrService(_env('VISION_CREDENTIALS_PATH'));
});

/// OCR offline — ML Kit on-device.
final localOcrServiceProvider = Provider<OcrService>((ref) {
  return MlKitOcrService();
});

/// true si VISION_CREDENTIALS_PATH está configurada → habilita Ruta 1 (Cloud Vision).
final visionKeyAvailableProvider = Provider<bool>((ref) {
  return _isSet('VISION_CREDENTIALS_PATH');
});

/// Use case orquestador del pipeline completo.
final parsePrescriptionUseCaseProvider = Provider<ParsePrescriptionUseCase>((ref) {
  return ParsePrescriptionUseCase(
    cloudOcr: ref.watch(cloudOcrServiceProvider),
    localOcr: ref.watch(localOcrServiceProvider),
    aiParser: ref.watch(aiParserServiceProvider),
    visionKeyAvailable: ref.watch(visionKeyAvailableProvider),
  );
});
