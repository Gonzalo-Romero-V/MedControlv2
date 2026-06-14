import '../entities/inference_result.dart';
import '../entities/med_time.dart';
import '../entities/patient_profile.dart';
import '../entities/treatment_facts.dart';

/// Motor de inferencia hacia adelante (forward chaining).
///
/// Clase Dart pura — sin dependencias de Flutter ni de base de datos.
/// Entrada: TreatmentFacts + PatientProfile + lista de medicamentos conflictivos.
/// Salida: InferenceResult con sugerencias, trazas completas y alertas de conflicto.
///
/// Reglas implementadas:
///   R01–R05: scheduling  R06: a demanda  R07: campos faltantes
///   R08–R09: snooze policy  R10: conflicto de principio activo
///   R11–R13: lifecycle → responsabilidad de use cases, no del motor.
class InferenceEngine {
  const InferenceEngine();

  static const MedTime _defaultStart = MedTime(8, 0);
  static const int _wakingStart = 7 * 60;   // 07:00
  static const int _wakingEnd = 22 * 60;    // 22:00
  static const List<String> _schedulingRules = ['R01', 'R02', 'R03', 'R04', 'R05'];

  /// [conflictingMedications]: nombres de medicamentos con el mismo principio activo
  /// que tienen tratamiento activo o suspendido. Los provee el use case consultando
  /// el repositorio — el motor permanece puro.
  InferenceResult inferSchedule(
    TreatmentFacts facts,
    PatientProfile profile, {
    List<String> conflictingMedications = const [],
  }) {
    // R07 — campos críticos faltantes: no inferir
    final missing = _checkMissingFields(facts);
    if (missing.isNotEmpty) {
      return InferenceResult.missingFields(missing);
    }

    // R06 — a demanda: sin horarios programados
    if (facts.frequencyType == FrequencyType.onDemand) {
      return InferenceResult.onDemand();
    }

    final traces = <InferenceTrace>[];
    List<MedTime> baseTimes;

    // R01 / R02 — base de tiempos por frecuencia
    if (facts.frequencyType == FrequencyType.everyNHours) {
      baseTimes = _applyR01(facts.frequencyValue!);
      final count = baseTimes.length;
      traces.add(InferenceTrace(
        ruleId: 'R01',
        condition: 'frecuencia = cada_${facts.frequencyValue}h',
        conclusion:
            '$count toma${count > 1 ? 's' : ''} diaria${count > 1 ? 's' : ''} desde 08:00',
        explanation:
            'la receta indica cada ${facts.frequencyValue} horas '
            '(→ $count toma${count > 1 ? 's' : ''} diaria${count > 1 ? 's' : ''})',
      ));
    } else {
      baseTimes = _applyR02(facts.frequencyValue!, profile);
      final n = facts.frequencyValue!;
      traces.add(InferenceTrace(
        ruleId: 'R02',
        condition: 'frecuencia = ${n}_veces_dia',
        conclusion:
            '$n toma${n > 1 ? 's' : ''} distribuidas en horas de vigilia (07:00–22:00)',
        explanation:
            'la receta indica $n vez${n > 1 ? 'es' : ''} al día '
            '(→ distribuidas en horas de vigilia)',
      ));
    }

    // R03 / R04 / R05 — instrucciones especiales (modifican base, mutuamente excluyentes)
    final instructions = (facts.specialInstructions ?? '').toLowerCase();
    bool specialApplied = false;

    if (_matches(instructions, [
      'con comida', 'después de comer', 'with food',
      'after meals', 'after eating', 'con alimentos',
    ])) {
      baseTimes = _applyR03(baseTimes.length, profile);
      traces.add(InferenceTrace(
        ruleId: 'R03',
        condition: 'instruccion contiene "con comida"',
        conclusion: 'anclar a ${_mealNames(baseTimes.length)} del perfil',
        explanation:
            'debe tomarse con comida '
            '(→ anclado a ${_mealNames(baseTimes.length)} de tu perfil)',
      ));
      specialApplied = true;
    }

    if (!specialApplied &&
        _matches(instructions, [
          'antes de dormir', 'before sleep', 'before bed', 'al acostarse',
        ])) {
      baseTimes = _applyR04(profile);
      traces.add(InferenceTrace(
        ruleId: 'R04',
        condition: 'instruccion contiene "antes de dormir"',
        conclusion: 'hora = sleepTime del perfil (${profile.sleepTime.format()})',
        explanation:
            'debe tomarse antes de dormir '
            '(→ hora de sueño de tu perfil: ${profile.sleepTime.format()})',
      ));
      specialApplied = true;
    }

    if (!specialApplied &&
        _matches(instructions, [
          'en ayunas', 'fasting', 'antes del desayuno',
          'before breakfast', 'antes de desayunar',
        ])) {
      baseTimes = _applyR05(profile);
      traces.add(InferenceTrace(
        ruleId: 'R05',
        condition: 'instruccion contiene "en ayunas"',
        conclusion:
            'hora = breakfastTime - 30min (${baseTimes.first.format()})',
        explanation: 'debe tomarse en ayunas (→ 30 minutos antes de tu desayuno)',
      ));
    }

    // R08 / R09 — política de posposición
    final snoozePolicy = _computeSnoozePolicy(facts);
    traces.add(InferenceTrace(
      ruleId: snoozePolicy.ruleId,
      condition: facts.isCritical ? 'es_critico = true' : 'es_critico = false',
      conclusion: facts.isCritical
          ? 'ventana = 30min, sin posposición'
          : 'ventana = ${_formatDuration(snoozePolicy.window.inMinutes)}, '
              '${snoozePolicy.maxSnoozes} posposiciones',
      explanation: snoozePolicy.explanation,
    ));

    // R10 — conflictos con tratamientos activos (datos provistos por el use case)
    final conflicts = conflictingMedications
        .map((name) => ConflictAlert(
              ruleId: 'R10',
              conflictingMedicationName: name,
              explanation:
                  'Ya existe un tratamiento activo o suspendido de "$name" '
                  '(mismo principio activo). Tomarlo simultáneamente puede ser '
                  'peligroso. Confirmación explícita requerida.',
            ))
        .toList();

    // Construir SuggestedTime referenciando solo las reglas de scheduling
    final scheduleRuleIds = traces
        .where((t) => _schedulingRules.contains(t.ruleId))
        .map((t) => t.ruleId)
        .toList();
    final explanation = _buildExplanation(traces, baseTimes);

    final suggestions = baseTimes
        .map((t) => SuggestedTime(
              time: t,
              ruleIds: List.unmodifiable(scheduleRuleIds),
              explanation: explanation,
            ))
        .toList();

    return InferenceResult(
      suggestions: suggestions,
      traces: traces,
      conflicts: conflicts,
      snoozePolicy: snoozePolicy,
    );
  }

  // ─── Reglas de horario ────────────────────────────────────────────────────

  /// R01: cada N horas → 24/N tomas desde 08:00
  List<MedTime> _applyR01(int intervalHours) {
    final count = (24 / intervalHours).round();
    return List.generate(count, (i) {
      final minutes = _defaultStart.totalMinutes + i * intervalHours * 60;
      return MedTime.fromMinutes(minutes);
    });
  }

  /// R02: N veces al día → distribuir en horas de vigilia (07:00–22:00)
  List<MedTime> _applyR02(int count, PatientProfile profile) {
    if (count == 1) return [_defaultStart];
    final interval = (_wakingEnd - _wakingStart) ~/ count;
    return List.generate(
        count, (i) => MedTime.fromMinutes(_wakingStart + i * interval));
  }

  /// R03: con comida → anclar a comidas del perfil del paciente
  List<MedTime> _applyR03(int doseCount, PatientProfile profile) {
    final meals = profile.mealTimes;
    if (doseCount >= meals.length) return meals;
    if (doseCount == 1) return [meals.first];
    if (doseCount == 2) return [meals.first, meals.last];
    return meals;
  }

  /// R04: antes de dormir → hora de sueño del perfil
  List<MedTime> _applyR04(PatientProfile profile) => [profile.sleepTime];

  /// R05: en ayunas → 30 min antes del desayuno
  List<MedTime> _applyR05(PatientProfile profile) =>
      [profile.breakfastTime.addMinutes(-30)];

  // ─── Reglas de posposición ────────────────────────────────────────────────

  /// R08: no crítico → ventana = intervalo/2, máx 3 posposiciones
  /// R09: crítico → ventana fija 30 min, sin posposición
  SnoozePolicy _computeSnoozePolicy(TreatmentFacts facts) {
    if (facts.isCritical) {
      return const SnoozePolicy(
        window: Duration(minutes: 30),
        maxSnoozes: 0,
        isCritical: true,
        ruleId: 'R09',
        explanation:
            'Este medicamento tiene ventana terapéutica estrecha. '
            'Debe tomarse a la hora exacta. Ventana máxima: 30 minutos.',
      );
    }
    final windowMinutes = _intervalMinutes(facts) ~/ 2;
    return SnoozePolicy(
      window: Duration(minutes: windowMinutes),
      maxSnoozes: 3,
      isCritical: false,
      ruleId: 'R08',
      explanation:
          'Podés posponer hasta ${_formatDuration(windowMinutes)} '
          '(mitad del intervalo entre dosis). '
          'Después de ese tiempo es mejor esperar la siguiente dosis.',
    );
  }

  // ─── Construcción de explicaciones ───────────────────────────────────────

  String _buildExplanation(List<InferenceTrace> traces, List<MedTime> times) {
    final parts = traces
        .where((t) => _schedulingRules.contains(t.ruleId))
        .map((t) => t.explanation)
        .toList();
    final timesStr = times.map((t) => t.format()).join(' y ');
    if (parts.isEmpty) return 'Horario sugerido: $timesStr.';
    return 'Se sugerió${times.length > 1 ? 'ron' : ''} $timesStr porque '
        '${parts.join(' y ')}.';
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────

  List<String> _checkMissingFields(TreatmentFacts facts) {
    final missing = <String>[];
    if (facts.doseAmount == null) missing.add('dosis');
    if (facts.doseUnit == null) missing.add('unidad de dosis');
    if (facts.frequencyType == null) {
      missing.add('frecuencia');
    } else if (facts.frequencyType == FrequencyType.everyNHours &&
        facts.frequencyValue == null) {
      missing.add('intervalo de horas');
    } else if (facts.frequencyType == FrequencyType.nTimesDay &&
        facts.frequencyValue == null) {
      missing.add('veces por día');
    }
    return missing;
  }

  bool _matches(String text, List<String> keywords) =>
      keywords.any((k) => text.contains(k));

  int _intervalMinutes(TreatmentFacts facts) {
    if (facts.frequencyType == FrequencyType.everyNHours &&
        facts.frequencyValue != null) {
      return facts.frequencyValue! * 60;
    }
    if (facts.frequencyType == FrequencyType.nTimesDay &&
        facts.frequencyValue != null &&
        facts.frequencyValue! > 0) {
      return (_wakingEnd - _wakingStart) ~/ facts.frequencyValue!;
    }
    return 8 * 60;
  }

  String _formatDuration(int minutes) {
    if (minutes < 60) return '$minutes minutos';
    final h = minutes ~/ 60;
    final m = minutes % 60;
    if (m == 0) return '$h hora${h > 1 ? 's' : ''}';
    return '$h h $m min';
  }

  String _mealNames(int count) {
    if (count == 1) return 'el desayuno';
    if (count == 2) return 'el desayuno y la cena';
    return 'el desayuno, el almuerzo y la cena';
  }
}
