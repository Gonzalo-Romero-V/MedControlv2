import '../entities/inference_result.dart';
import '../entities/med_time.dart';
import '../entities/patient_profile.dart';
import '../entities/treatment_facts.dart';

/// Motor de inferencia hacia adelante (forward chaining).
///
/// Clase Dart pura — sin dependencias de Flutter ni de base de datos.
/// Entrada: TreatmentFacts + PatientProfile.
/// Salida: InferenceResult con horarios sugeridos y trazas de reglas.
///
/// Reglas implementadas: R01–R09 (scheduling y posposición).
/// R10–R13 (lifecycle) son responsabilidad de los use cases.
class InferenceEngine {
  const InferenceEngine();

  static const MedTime _defaultStart = MedTime(8, 0);
  static const int _wakingStart = 7 * 60;   // 07:00 en minutos
  static const int _wakingEnd = 22 * 60;    // 22:00 en minutos

  InferenceResult inferSchedule(
    TreatmentFacts facts,
    PatientProfile profile,
  ) {
    // R07 — campos críticos faltantes: no inferir
    final missing = _checkMissingFields(facts);
    if (missing.isNotEmpty) {
      return InferenceResult.missingFields(missing);
    }

    // R06 — a demanda: sin horarios programados
    if (facts.frequencyType == FrequencyType.onDemand) {
      return InferenceResult.onDemand();
    }

    // R01 / R02 — base de tiempos por frecuencia
    final List<String> appliedRules = [];
    List<MedTime> baseTimes;

    if (facts.frequencyType == FrequencyType.everyNHours) {
      baseTimes = _applyR01(facts.frequencyValue!);
      appliedRules.add('R01');
    } else {
      baseTimes = _applyR02(facts.frequencyValue!, profile);
      appliedRules.add('R02');
    }

    // R03 / R04 / R05 — instrucciones especiales (modifican base)
    final instructions = (facts.specialInstructions ?? '').toLowerCase();
    bool r03Applied = false;

    if (_matches(instructions, ['con comida', 'después de comer',
        'with food', 'after meals', 'after eating', 'con alimentos'])) {
      baseTimes = _applyR03(baseTimes.length, profile);
      appliedRules.add('R03');
      r03Applied = true;
    }

    if (!r03Applied &&
        _matches(instructions, ['antes de dormir', 'before sleep',
            'before bed', 'al acostarse'])) {
      baseTimes = _applyR04(profile);
      appliedRules.add('R04');
    }

    if (!r03Applied &&
        _matches(instructions, ['en ayunas', 'fasting', 'antes del desayuno',
            'before breakfast', 'antes de desayunar'])) {
      baseTimes = _applyR05(profile);
      appliedRules.add('R05');
    }

    // Construir SuggestedTime con explicación trazada
    final suggestions = _buildSuggestions(
      baseTimes,
      appliedRules,
      facts,
      profile,
    );

    // R08 / R09 — política de posposición
    final snoozePolicy = _computeSnoozePolicy(facts);

    return InferenceResult(
      suggestions: suggestions,
      appliedRules: appliedRules,
      snoozePolicy: snoozePolicy,
    );
  }

  // ─── Reglas de horario ────────────────────────────────────────────────────

  /// R01: cada N horas → 24/N tomas distribuidas desde 08:00
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
    return List.generate(count, (i) {
      return MedTime.fromMinutes(_wakingStart + i * interval);
    });
  }

  /// R03: con comida → anclar a comidas del perfil
  /// Si la dosis no coincide con el número de comidas, toma un subconjunto.
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

    // Calcular ventana según frecuencia (R08)
    final intervalMinutes = _intervalMinutes(facts);
    final windowMinutes = intervalMinutes ~/ 2;

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

  List<SuggestedTime> _buildSuggestions(
    List<MedTime> times,
    List<String> ruleIds,
    TreatmentFacts facts,
    PatientProfile profile,
  ) {
    final timesStr = times.map((t) => t.format()).join(', ');
    final baseExplanation = _buildExplanation(ruleIds, facts, times, profile);

    return times
        .map((t) => SuggestedTime(
              time: t,
              ruleIds: List.unmodifiable(ruleIds),
              explanation: baseExplanation,
            ))
        .toList();
  }

  String _buildExplanation(
    List<String> ruleIds,
    TreatmentFacts facts,
    List<MedTime> times,
    PatientProfile profile,
  ) {
    final parts = <String>[];
    final timesStr = times.map((t) => t.format()).join(' y ');

    // Parte de frecuencia (R01 o R02)
    if (ruleIds.contains('R01')) {
      final n = facts.frequencyValue!;
      final count = times.length;
      parts.add(
        'la receta indica cada $n horas (→ $count toma${count > 1 ? 's' : ''} diaria${count > 1 ? 's' : ''})',
      );
    } else if (ruleIds.contains('R02')) {
      final n = facts.frequencyValue!;
      parts.add(
        'la receta indica $n vez${n > 1 ? 'es' : ''} al día (→ distribuidas en horas de vigilia)',
      );
    }

    // Parte de instrucción especial (R03, R04, R05)
    if (ruleIds.contains('R03')) {
      parts.add(
        'debe tomarse con comida (→ anclado a ${_mealNames(times.length)} de tu perfil)',
      );
    } else if (ruleIds.contains('R04')) {
      parts.add(
        'debe tomarse antes de dormir (→ hora de sueño de tu perfil: ${profile.sleepTime.format()})',
      );
    } else if (ruleIds.contains('R05')) {
      parts.add(
        'debe tomarse en ayunas (→ 30 minutos antes de tu desayuno)',
      );
    }

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
    // Para n_veces_dia, aproximar intervalo como horas vigilia / N
    if (facts.frequencyType == FrequencyType.nTimesDay &&
        facts.frequencyValue != null && facts.frequencyValue! > 0) {
      return (_wakingEnd - _wakingStart) ~/ facts.frequencyValue!;
    }
    return 8 * 60; // default conservador
  }

  String _formatDuration(int minutes) {
    if (minutes < 60) return '$minutes minutos';
    final h = minutes ~/ 60;
    final m = minutes % 60;
    if (m == 0) return '$h hora${h > 1 ? 's' : ''}';
    return '$h h ${m} min';
  }

  String _mealNames(int count) {
    if (count == 1) return 'el desayuno';
    if (count == 2) return 'el desayuno y la cena';
    return 'el desayuno, el almuerzo y la cena';
  }
}
