import 'package:equatable/equatable.dart';

import 'treatment_facts.dart';

enum PrescriptionSource { cloudVisionGemini, mlkitManual }

/// Output tipado del pipeline OCR → AI parser.
/// Se muestra en la pantalla de revisión antes de confirmar el tratamiento.
/// Mapea 1:1 a TreatmentFacts cuando el usuario confirma.
class ParsedPrescription extends Equatable {
  final String? medicationName;
  final String? activeIngredient;
  final double? doseAmount;
  final String? doseUnit;
  final FrequencyType? frequencyType;
  final int? frequencyValue;
  final String? route;
  final String? specialInstructions;
  final String? endCriterionType;
  final int? durationDays;
  final int? totalDoses;
  final bool isCritical;

  /// Texto OCR crudo — preservado siempre como fuente de auditoría.
  final String rawOcrText;

  /// Respuesta JSON cruda del modelo — preservada para debugging.
  final String? rawAiResponse;

  final PrescriptionSource source;

  const ParsedPrescription({
    this.medicationName,
    this.activeIngredient,
    this.doseAmount,
    this.doseUnit,
    this.frequencyType,
    this.frequencyValue,
    this.route,
    this.specialInstructions,
    this.endCriterionType,
    this.durationDays,
    this.totalDoses,
    this.isCritical = false,
    required this.rawOcrText,
    this.rawAiResponse,
    required this.source,
  });

  /// true cuando están todos los campos críticos para crear recordatorios
  bool get hasCriticalFields =>
      medicationName != null &&
      doseAmount != null &&
      doseUnit != null &&
      frequencyType != null &&
      (frequencyType == FrequencyType.onDemand ||
          frequencyType == FrequencyType.tapering ||
          frequencyValue != null);

  /// Convierte a TreatmentFacts para alimentar el InferenceEngine
  TreatmentFacts toTreatmentFacts({required DateTime startDate}) =>
      TreatmentFacts(
        medicationName: medicationName ?? '',
        doseAmount: doseAmount,
        doseUnit: doseUnit,
        frequencyType: frequencyType,
        frequencyValue: frequencyValue,
        specialInstructions: specialInstructions,
        isCritical: isCritical,
        startDate: startDate,
      );

  @override
  List<Object?> get props => [
        medicationName,
        activeIngredient,
        doseAmount,
        doseUnit,
        frequencyType,
        frequencyValue,
        route,
        specialInstructions,
        endCriterionType,
        durationDays,
        totalDoses,
        isCritical,
        rawOcrText,
        rawAiResponse,
        source,
      ];
}
