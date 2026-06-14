import 'package:equatable/equatable.dart';

import 'med_time.dart';

/// Traza completa de una regla aplicada: condición → conclusión + explicación humana.
class InferenceTrace extends Equatable {
  final String ruleId;
  final String condition;    // qué disparó la regla
  final String conclusion;   // qué produjo
  final String explanation;  // texto en español para mostrar al usuario

  const InferenceTrace({
    required this.ruleId,
    required this.condition,
    required this.conclusion,
    required this.explanation,
  });

  @override
  List<Object?> get props => [ruleId, condition, conclusion, explanation];
}

/// Alerta de conflicto generada por R10 — tratamiento activo del mismo principio activo.
class ConflictAlert extends Equatable {
  final String ruleId;  // siempre 'R10'
  final String conflictingMedicationName;
  final String explanation;

  const ConflictAlert({
    required this.ruleId,
    required this.conflictingMedicationName,
    required this.explanation,
  });

  @override
  List<Object?> get props => [ruleId, conflictingMedicationName, explanation];
}

/// Un horario sugerido con referencias a las reglas de scheduling que lo generaron.
class SuggestedTime extends Equatable {
  final MedTime time;

  /// IDs de reglas de scheduling que produjeron este horario (subconjunto de InferenceResult.traces)
  final List<String> ruleIds;

  /// Explicación en español derivada de las trazas aplicables
  final String explanation;

  const SuggestedTime({
    required this.time,
    required this.ruleIds,
    required this.explanation,
  });

  @override
  List<Object?> get props => [time, ruleIds, explanation];
}

/// Información sobre la ventana de posposición calculada para este tratamiento.
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
///
/// Incluye horarios sugeridos, trazas completas de cada regla aplicada,
/// alertas de conflicto (R10) y política de posposición (R08/R09).
class InferenceResult extends Equatable {
  final List<SuggestedTime> suggestions;

  /// Trazas de todas las reglas que se evaluaron y dispararon.
  final List<InferenceTrace> traces;

  final List<String> missingFields;

  /// Alertas de conflicto con tratamientos activos — generadas por R10.
  /// El use case decide si bloquear o pedir confirmación explícita.
  final List<ConflictAlert> conflicts;

  final SnoozePolicy? snoozePolicy;
  final bool isOnDemand;

  const InferenceResult({
    required this.suggestions,
    required this.traces,
    this.missingFields = const [],
    this.conflicts = const [],
    this.snoozePolicy,
    this.isOnDemand = false,
  });

  /// IDs de todas las reglas aplicadas — derivado de traces.
  List<String> get appliedRules =>
      traces.map((t) => t.ruleId).toSet().toList();

  bool get hasMissingFields => missingFields.isNotEmpty;
  bool get hasConflicts => conflicts.isNotEmpty;
  bool get canCreateReminders => !hasMissingFields && !isOnDemand;

  factory InferenceResult.missingFields(List<String> fields) =>
      InferenceResult(
        suggestions: const [],
        traces: const [
          InferenceTrace(
            ruleId: 'R07',
            condition: 'falta campo crítico',
            conclusion: 'no inferir horarios',
            explanation:
                'No se pueden calcular horarios porque faltan datos '
                'obligatorios de la receta.',
          ),
        ],
        missingFields: fields,
      );

  factory InferenceResult.onDemand() => const InferenceResult(
        suggestions: [],
        traces: [
          InferenceTrace(
            ruleId: 'R06',
            condition: 'frecuencia = a_demanda',
            conclusion: 'sin horarios programados',
            explanation:
                'Este medicamento se toma cuando el paciente lo necesita. '
                'No genera recordatorios automáticos.',
          ),
        ],
        isOnDemand: true,
      );

  @override
  List<Object?> get props =>
      [suggestions, traces, missingFields, conflicts, snoozePolicy, isOnDemand];
}
