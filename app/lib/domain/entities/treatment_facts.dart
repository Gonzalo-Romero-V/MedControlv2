import 'package:equatable/equatable.dart';

enum FrequencyType { everyNHours, nTimesDay, onDemand, tapering }

/// Hechos de un tratamiento — entrada al motor de inferencia.
/// Son los datos extraídos de la receta, antes de ser confirmados.
class TreatmentFacts extends Equatable {
  final String medicationName;
  final double? doseAmount;
  final String? doseUnit;
  final FrequencyType? frequencyType;

  /// N en "cada N horas" o "N veces al día"
  final int? frequencyValue;

  /// Instrucciones especiales de la receta
  final String? specialInstructions;

  final bool isCritical;
  final DateTime startDate;

  const TreatmentFacts({
    required this.medicationName,
    this.doseAmount,
    this.doseUnit,
    this.frequencyType,
    this.frequencyValue,
    this.specialInstructions,
    this.isCritical = false,
    required this.startDate,
  });

  bool get hasMissingCriticalFields =>
      doseAmount == null ||
      doseUnit == null ||
      frequencyType == null ||
      (frequencyType == FrequencyType.everyNHours && frequencyValue == null) ||
      (frequencyType == FrequencyType.nTimesDay && frequencyValue == null);

  @override
  List<Object?> get props => [
        medicationName,
        doseAmount,
        doseUnit,
        frequencyType,
        frequencyValue,
        specialInstructions,
        isCritical,
        startDate,
      ];
}
