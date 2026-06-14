import 'package:equatable/equatable.dart';

import 'med_time.dart';

/// Un horario sugerido con la traza completa de las reglas que lo generaron.
class SuggestedTime extends Equatable {
  final MedTime time;

  /// IDs de reglas canónicas que produjeron este horario (ej: ['R01', 'R03'])
  final List<String> ruleIds;

  /// Explicación en español para mostrar al usuario
  final String explanation;

  const SuggestedTime({
    required this.time,
    required this.ruleIds,
    required this.explanation,
  });

  @override
  List<Object?> get props => [time, ruleIds, explanation];
}

/// Información sobre la ventana de posposición calculada para este tratamiento
class SnoozePolicy extends Equatable {
  final Duration window;
  final int maxSnoozes;
  final bool isCritical;
  final String ruleId;
  final String explanation;

  const SnoozePolicy({
    required this.window,
    required this.maxSnoozes,
    required this.isCritical,
    required this.ruleId,
    required this.explanation,
  });

  Duration get snoozeInterval =>
      maxSnoozes > 0 ? window ~/ maxSnoozes : Duration.zero;

  @override
  List<Object?> get props =>
      [window, maxSnoozes, isCritical, ruleId, explanation];
}

/// Resultado completo del motor de inferencia.
class InferenceResult extends Equatable {
  final List<SuggestedTime> suggestions;
  final List<String> appliedRules;
  final List<String> missingFields;
  final SnoozePolicy? snoozePolicy;
  final bool isOnDemand;

  const InferenceResult({
    required this.suggestions,
    required this.appliedRules,
    this.missingFields = const [],
    this.snoozePolicy,
    this.isOnDemand = false,
  });

  bool get hasMissingFields => missingFields.isNotEmpty;
  bool get canCreateReminders => !hasMissingFields && !isOnDemand;

  /// Sin horarios porque faltan campos críticos
  factory InferenceResult.missingFields(List<String> fields) =>
      InferenceResult(
        suggestions: const [],
        appliedRules: const ['R07'],
        missingFields: fields,
      );

  /// Sin horarios porque es medicamento a demanda
  factory InferenceResult.onDemand() => const InferenceResult(
        suggestions: [],
        appliedRules: ['R06'],
        isOnDemand: true,
      );

  @override
  List<Object?> get props =>
      [suggestions, appliedRules, missingFields, snoozePolicy, isOnDemand];
}
