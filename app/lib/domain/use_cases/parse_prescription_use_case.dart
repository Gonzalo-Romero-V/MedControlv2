import 'dart:io';

import '../entities/parsed_prescription.dart';
import '../services/ai_parser_service.dart';
import '../services/ocr_service.dart';

/// Resultado del pipeline de parseo de receta.
sealed class ParsePrescriptionResult {}

/// Ruta 1 exitosa: Cloud Vision + AI parser → entidades estructuradas.
final class FullParse extends ParsePrescriptionResult {
  final ParsedPrescription prescription;
  FullParse(this.prescription);
}

/// Ruta 2 (fallback offline): ML Kit → solo texto crudo para formulario manual.
final class OcrOnly extends ParsePrescriptionResult {
  final String rawText;
  OcrOnly(this.rawText);
}

/// Ambas rutas fallaron — mostrar formulario manual vacío + mensaje.
final class ParseFailure extends ParsePrescriptionResult {
  final String message;
  ParseFailure(this.message);
}

/// Orquestador del pipeline OCR → AI.
///
/// Ruta 1 (online, preferida):
///   imagen → [cloudOcr] → texto → [aiParser] → ParsedPrescription
///
/// Ruta 2 (fallback offline):
///   imagen → [localOcr] → texto crudo → OcrOnly (va al formulario manual)
///
/// El use case intenta Ruta 1; ante cualquier error de red o de API, cae a Ruta 2.
/// Si Ruta 2 también falla, devuelve ParseFailure.
class ParsePrescriptionUseCase {
  final OcrService cloudOcr;
  final OcrService localOcr;
  final AiParserService aiParser;

  /// true si VISION_API_KEY está configurada y no vacía.
  /// Lo provee el provider Riverpod leyendo el env. Determina si se intenta Ruta 1.
  final bool visionKeyAvailable;

  const ParsePrescriptionUseCase({
    required this.cloudOcr,
    required this.localOcr,
    required this.aiParser,
    required this.visionKeyAvailable,
  });

  Future<ParsePrescriptionResult> execute(File imageFile) async {
    // Ruta 1: requiere VISION_API_KEY + conectividad
    if (visionKeyAvailable) {
      try {
        final ocrText = await cloudOcr.extractText(imageFile);
        final prescription = await aiParser.parse(ocrText);
        return FullParse(prescription);
      } catch (_) {
        // Cualquier error de red o API → caer a Ruta 2
      }
    }

    // Ruta 2: ML Kit on-device
    try {
      final rawText = await localOcr.extractText(imageFile);
      return OcrOnly(rawText);
    } catch (e) {
      return ParseFailure(
        'No se pudo extraer texto de la imagen. '
        'Podés ingresar los datos manualmente.',
      );
    }
  }
}
