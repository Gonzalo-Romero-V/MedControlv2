import '../entities/parsed_prescription.dart';

/// Interfaz del parser semántico de recetas.
/// Recibe texto OCR crudo, devuelve entidades estructuradas.
/// Implementaciones: GeminiParserService, OpenAiParserService.
abstract class AiParserService {
  Future<ParsedPrescription> parse(String ocrText);
}
