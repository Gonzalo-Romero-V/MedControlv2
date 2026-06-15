import 'dart:io';

import 'package:flutter/foundation.dart';

import '../entities/parsed_prescription.dart';
import '../services/ai_parser_service.dart';
import '../services/ocr_service.dart';

/// Resultado del pipeline de parseo de receta.
sealed class ParsePrescriptionResult {}

/// Ruta 1 exitosa: OCR + AI parser → entidades estructuradas.
/// [usedCloudVision] = true si Cloud Vision hizo el OCR; false si fue ML Kit.
final class FullParse extends ParsePrescriptionResult {
  final ParsedPrescription prescription;
  final bool usedCloudVision;
  FullParse(this.prescription, {required this.usedCloudVision});
}

/// OCR exitoso pero sin parseo IA → solo texto crudo para formulario manual.
/// [usedCloudVision] = true si Cloud Vision hizo el OCR; false si fue ML Kit.
final class OcrOnly extends ParsePrescriptionResult {
  final String rawText;
  final bool usedCloudVision;
  OcrOnly(this.rawText, {required this.usedCloudVision});
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

  final bool aiKeyAvailable;

  const ParsePrescriptionUseCase({
    required this.cloudOcr,
    required this.localOcr,
    required this.aiParser,
    required this.visionKeyAvailable,
    required this.aiKeyAvailable,
  });

  Future<ParsePrescriptionResult> execute(File imageFile) async {
    debugPrint('[Pipeline] visionKey=$visionKeyAvailable aiKey=$aiKeyAvailable');

    // Paso 1: Obtener texto OCR — Cloud Vision preferido, ML Kit como fallback
    String? ocrText;
    bool usedCloudVision = false;

    if (visionKeyAvailable) {
      try {
        ocrText = await cloudOcr.extractText(imageFile);
        usedCloudVision = true;
        debugPrint('[Pipeline] Cloud Vision OK — ${ocrText.length} chars');
      } catch (e) {
        debugPrint('[Pipeline] Cloud Vision FAILED: $e');
      }
    }

    if (ocrText == null) {
      try {
        ocrText = await localOcr.extractText(imageFile);
        debugPrint('[Pipeline] ML Kit OK — ${ocrText.length} chars');
      } catch (e) {
        debugPrint('[Pipeline] ML Kit FAILED: $e');
        return ParseFailure(
          'No se pudo extraer texto de la imagen. '
          'Podés ingresar los datos manualmente.',
        );
      }
    }

    // Paso 2: Parseo IA con el texto disponible (Cloud Vision o ML Kit)
    if (aiKeyAvailable) {
      try {
        final prescription = await aiParser.parse(ocrText);
        debugPrint('[Pipeline] AI parse OK → FullParse (cloudVision=$usedCloudVision)');
        return FullParse(prescription, usedCloudVision: usedCloudVision);
      } catch (e) {
        debugPrint('[Pipeline] AI parse FAILED: $e');
        return OcrOnly(ocrText, usedCloudVision: usedCloudVision);
      }
    }

    debugPrint('[Pipeline] No AI key → OcrOnly (cloudVision=$usedCloudVision)');
    return OcrOnly(ocrText, usedCloudVision: usedCloudVision);
  }
}
