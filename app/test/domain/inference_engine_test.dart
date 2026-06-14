import 'package:flutter_test/flutter_test.dart';

import 'package:med_control/domain/entities/inference_result.dart';
import 'package:med_control/domain/entities/med_time.dart';
import 'package:med_control/domain/entities/patient_profile.dart';
import 'package:med_control/domain/entities/treatment_facts.dart';
import 'package:med_control/domain/services/inference_engine.dart';

void main() {
  const engine = InferenceEngine();
  const profile = PatientProfile.defaults;

  // ─── Helper ────────────────────────────────────────────────────────────────

  TreatmentFacts baseFacts({
    FrequencyType type = FrequencyType.everyNHours,
    int? value = 8,
    String? instructions,
    bool isCritical = false,
  }) =>
      TreatmentFacts(
        medicationName: 'TestMed',
        doseAmount: 500,
        doseUnit: 'mg',
        frequencyType: type,
        frequencyValue: value,
        specialInstructions: instructions,
        isCritical: isCritical,
        startDate: DateTime(2026, 1, 1),
      );

  // ─── R07: campos faltantes ─────────────────────────────────────────────────

  group('R07 — campos faltantes', () {
    test('retorna missingFields cuando falta doseAmount', () {
      final facts = TreatmentFacts(
        medicationName: 'Med',
        doseUnit: 'mg',
        frequencyType: FrequencyType.everyNHours,
        frequencyValue: 8,
        startDate: DateTime(2026, 1, 1),
      );
      final result = engine.inferSchedule(facts, profile);

      expect(result.hasMissingFields, isTrue);
      expect(result.missingFields, contains('dosis'));
      expect(result.suggestions, isEmpty);
      expect(result.appliedRules, contains('R07'));
    });

    test('traza R07 tiene condición y conclusión correctas', () {
      final facts = TreatmentFacts(
        medicationName: 'Med',
        startDate: DateTime(2026, 1, 1),
      );
      final result = engine.inferSchedule(facts, profile);

      expect(result.traces, hasLength(1));
      expect(result.traces.first.ruleId, equals('R07'));
      expect(result.traces.first.condition, contains('campo crítico'));
      expect(result.traces.first.conclusion, contains('no inferir'));
    });

    test('retorna missingFields cuando falta frequencyValue para everyNHours', () {
      final facts = TreatmentFacts(
        medicationName: 'Med',
        doseAmount: 250,
        doseUnit: 'mg',
        frequencyType: FrequencyType.everyNHours,
        startDate: DateTime(2026, 1, 1),
      );
      expect(
        engine.inferSchedule(facts, profile).missingFields,
        contains('intervalo de horas'),
      );
    });

    test('retorna missingFields cuando falta frequencyValue para nTimesDay', () {
      final facts = TreatmentFacts(
        medicationName: 'Med',
        doseAmount: 250,
        doseUnit: 'mg',
        frequencyType: FrequencyType.nTimesDay,
        startDate: DateTime(2026, 1, 1),
      );
      expect(
        engine.inferSchedule(facts, profile).missingFields,
        contains('veces por día'),
      );
    });
  });

  // ─── R06: a demanda ────────────────────────────────────────────────────────

  group('R06 — a demanda', () {
    test('retorna isOnDemand sin horarios', () {
      final result = engine.inferSchedule(
        baseFacts(type: FrequencyType.onDemand, value: null),
        profile,
      );

      expect(result.isOnDemand, isTrue);
      expect(result.suggestions, isEmpty);
      expect(result.canCreateReminders, isFalse);
      expect(result.appliedRules, contains('R06'));
    });

    test('traza R06 tiene condición correcta', () {
      final result = engine.inferSchedule(
        baseFacts(type: FrequencyType.onDemand, value: null),
        profile,
      );

      expect(result.traces.first.ruleId, equals('R06'));
      expect(result.traces.first.condition, contains('a_demanda'));
    });
  });

  // ─── R01: cada N horas ─────────────────────────────────────────────────────

  group('R01 — cada N horas', () {
    test('cada 8 horas → 3 tomas desde 08:00', () {
      final result = engine.inferSchedule(baseFacts(value: 8), profile);

      expect(result.appliedRules, contains('R01'));
      expect(result.suggestions, hasLength(3));
      expect(result.suggestions[0].time, equals(const MedTime(8, 0)));
      expect(result.suggestions[1].time, equals(const MedTime(16, 0)));
      expect(result.suggestions[2].time, equals(const MedTime(0, 0)));
    });

    test('cada 12 horas → 2 tomas', () {
      final result = engine.inferSchedule(baseFacts(value: 12), profile);

      expect(result.suggestions, hasLength(2));
      expect(result.suggestions[0].time, equals(const MedTime(8, 0)));
      expect(result.suggestions[1].time, equals(const MedTime(20, 0)));
    });

    test('cada 6 horas → 4 tomas', () {
      final result = engine.inferSchedule(baseFacts(value: 6), profile);

      expect(result.suggestions, hasLength(4));
      expect(result.suggestions[0].time, equals(const MedTime(8, 0)));
      expect(result.suggestions[1].time, equals(const MedTime(14, 0)));
      expect(result.suggestions[2].time, equals(const MedTime(20, 0)));
      expect(result.suggestions[3].time, equals(const MedTime(2, 0)));
    });

    test('cada 24 horas → 1 toma', () {
      final result = engine.inferSchedule(baseFacts(value: 24), profile);

      expect(result.suggestions, hasLength(1));
      expect(result.suggestions[0].time, equals(const MedTime(8, 0)));
    });

    test('traza R01 contiene condición y conclusión correctas', () {
      final result = engine.inferSchedule(baseFacts(value: 8), profile);
      final trace = result.traces.firstWhere((t) => t.ruleId == 'R01');

      expect(trace.condition, contains('cada_8h'));
      expect(trace.conclusion, contains('3 tomas'));
      expect(trace.explanation, isNotEmpty);
    });
  });

  // ─── R02: N veces al día ───────────────────────────────────────────────────

  group('R02 — N veces al día', () {
    test('1 vez al día → 1 toma a las 08:00', () {
      final result = engine.inferSchedule(
        baseFacts(type: FrequencyType.nTimesDay, value: 1),
        profile,
      );

      expect(result.appliedRules, contains('R02'));
      expect(result.suggestions, hasLength(1));
      expect(result.suggestions[0].time, equals(const MedTime(8, 0)));
    });

    test('2 veces al día → 2 tomas distribuidas en vigilia', () {
      final result = engine.inferSchedule(
        baseFacts(type: FrequencyType.nTimesDay, value: 2),
        profile,
      );

      expect(result.suggestions, hasLength(2));
      expect(result.suggestions[0].time, equals(const MedTime(7, 0)));
      expect(result.suggestions[1].time, equals(const MedTime(14, 30)));
    });

    test('3 veces al día → 3 tomas en vigilia', () {
      final result = engine.inferSchedule(
        baseFacts(type: FrequencyType.nTimesDay, value: 3),
        profile,
      );

      expect(result.suggestions, hasLength(3));
    });
  });

  // ─── R03: con comida ───────────────────────────────────────────────────────

  group('R03 — con comida', () {
    test('instrucción "con comida" ancla a comidas del perfil', () {
      final result = engine.inferSchedule(
        baseFacts(
          type: FrequencyType.nTimesDay,
          value: 3,
          instructions: 'tomar con comida',
        ),
        profile,
      );

      expect(result.appliedRules, contains('R03'));
      final times = result.suggestions.map((s) => s.time).toList();
      expect(times, contains(const MedTime(7, 0)));
      expect(times, contains(const MedTime(13, 0)));
      expect(times, contains(const MedTime(19, 0)));
    });

    test('1 dosis con comida → solo desayuno', () {
      final result = engine.inferSchedule(
        baseFacts(
          type: FrequencyType.nTimesDay,
          value: 1,
          instructions: 'con alimentos',
        ),
        profile,
      );

      expect(result.suggestions, hasLength(1));
      expect(result.suggestions[0].time, equals(const MedTime(7, 0)));
    });

    test('2 dosis con comida → desayuno y cena', () {
      final result = engine.inferSchedule(
        baseFacts(
          type: FrequencyType.nTimesDay,
          value: 2,
          instructions: 'with food',
        ),
        profile,
      );

      expect(result.suggestions, hasLength(2));
      expect(result.suggestions[0].time, equals(const MedTime(7, 0)));
      expect(result.suggestions[1].time, equals(const MedTime(19, 0)));
    });

    test('traza R03 tiene condición y conclusión correctas', () {
      final result = engine.inferSchedule(
        baseFacts(
          type: FrequencyType.nTimesDay,
          value: 3,
          instructions: 'con comida',
        ),
        profile,
      );

      final trace = result.traces.firstWhere((t) => t.ruleId == 'R03');
      expect(trace.condition, contains('"con comida"'));
      expect(trace.conclusion, contains('perfil'));
      expect(trace.explanation, isNotEmpty);
    });
  });

  // ─── R04: antes de dormir ──────────────────────────────────────────────────

  group('R04 — antes de dormir', () {
    test('instrucción "antes de dormir" ancla a sleepTime del perfil', () {
      final result = engine.inferSchedule(
        baseFacts(
          type: FrequencyType.nTimesDay,
          value: 1,
          instructions: 'tomar antes de dormir',
        ),
        profile,
      );

      expect(result.appliedRules, contains('R04'));
      expect(result.suggestions, hasLength(1));
      expect(result.suggestions[0].time, equals(const MedTime(21, 0)));
    });

    test('instrucción "al acostarse" también activa R04', () {
      final result = engine.inferSchedule(
        baseFacts(
          type: FrequencyType.nTimesDay,
          value: 1,
          instructions: 'al acostarse',
        ),
        profile,
      );

      expect(result.appliedRules, contains('R04'));
    });

    test('R04 respeta sleepTime personalizado del perfil', () {
      const customProfile = PatientProfile(
        breakfastTime: MedTime(8, 0),
        lunchTime: MedTime(13, 0),
        dinnerTime: MedTime(20, 0),
        sleepTime: MedTime(23, 30),
      );
      final result = engine.inferSchedule(
        baseFacts(
          type: FrequencyType.nTimesDay,
          value: 1,
          instructions: 'before bed',
        ),
        customProfile,
      );

      expect(result.suggestions[0].time, equals(const MedTime(23, 30)));
    });
  });

  // ─── R05: en ayunas ────────────────────────────────────────────────────────

  group('R05 — en ayunas', () {
    test('instrucción "en ayunas" → 30 min antes del desayuno', () {
      final result = engine.inferSchedule(
        baseFacts(
          type: FrequencyType.nTimesDay,
          value: 1,
          instructions: 'tomar en ayunas',
        ),
        profile,
      );

      expect(result.appliedRules, contains('R05'));
      expect(result.suggestions, hasLength(1));
      expect(result.suggestions[0].time, equals(const MedTime(6, 30)));
    });

    test('R03 tiene precedencia sobre R05', () {
      final result = engine.inferSchedule(
        baseFacts(
          type: FrequencyType.nTimesDay,
          value: 1,
          instructions: 'con comida en ayunas',
        ),
        profile,
      );

      expect(result.appliedRules, contains('R03'));
      expect(result.appliedRules, isNot(contains('R05')));
    });
  });

  // ─── R08: snooze estándar ─────────────────────────────────────────────────

  group('R08 — snooze estándar', () {
    test('cada 8h → ventana 4h, 3 posposiciones', () {
      final result = engine.inferSchedule(baseFacts(value: 8), profile);

      expect(result.snoozePolicy!.isCritical, isFalse);
      expect(result.snoozePolicy!.window, equals(const Duration(hours: 4)));
      expect(result.snoozePolicy!.maxSnoozes, equals(3));
      expect(result.snoozePolicy!.ruleId, equals('R08'));
    });

    test('cada 12h → ventana 6h', () {
      expect(
        engine.inferSchedule(baseFacts(value: 12), profile).snoozePolicy!.window,
        equals(const Duration(hours: 6)),
      );
    });

    test('snoozeInterval = window / maxSnoozes', () {
      final policy = engine.inferSchedule(baseFacts(value: 6), profile).snoozePolicy!;

      expect(policy.window, equals(const Duration(hours: 3)));
      expect(policy.snoozeInterval, equals(const Duration(hours: 1)));
    });

    test('traza R08 aparece en traces', () {
      final traces = engine.inferSchedule(baseFacts(value: 8), profile).traces;
      final trace = traces.firstWhere((t) => t.ruleId == 'R08');

      expect(trace.condition, contains('es_critico = false'));
      expect(trace.conclusion, contains('3 posposiciones'));
    });
  });

  // ─── R09: snooze crítico ──────────────────────────────────────────────────

  group('R09 — snooze crítico', () {
    test('isCritical=true → ventana 30min, 0 posposiciones', () {
      final result = engine.inferSchedule(
        baseFacts(isCritical: true),
        profile,
      );

      expect(result.snoozePolicy!.isCritical, isTrue);
      expect(result.snoozePolicy!.window, equals(const Duration(minutes: 30)));
      expect(result.snoozePolicy!.maxSnoozes, equals(0));
      expect(result.snoozePolicy!.ruleId, equals('R09'));
    });

    test('snoozeInterval es cero para medicamentos críticos', () {
      expect(
        engine.inferSchedule(baseFacts(isCritical: true), profile)
            .snoozePolicy!.snoozeInterval,
        equals(Duration.zero),
      );
    });

    test('traza R09 aparece en traces', () {
      final traces = engine
          .inferSchedule(baseFacts(isCritical: true), profile)
          .traces;
      final trace = traces.firstWhere((t) => t.ruleId == 'R09');

      expect(trace.condition, contains('es_critico = true'));
      expect(trace.conclusion, contains('sin posposición'));
    });
  });

  // ─── R10: conflictos ──────────────────────────────────────────────────────

  group('R10 — conflictos de principio activo', () {
    test('sin conflictos → hasConflicts false', () {
      final result = engine.inferSchedule(baseFacts(value: 8), profile);

      expect(result.hasConflicts, isFalse);
      expect(result.conflicts, isEmpty);
    });

    test('un medicamento conflictivo → ConflictAlert con R10', () {
      final result = engine.inferSchedule(
        baseFacts(value: 8),
        profile,
        conflictingMedications: ['Ibuprofeno 400mg'],
      );

      expect(result.hasConflicts, isTrue);
      expect(result.conflicts, hasLength(1));
      expect(result.conflicts.first.ruleId, equals('R10'));
      expect(result.conflicts.first.conflictingMedicationName,
          equals('Ibuprofeno 400mg'));
      expect(result.conflicts.first.explanation, isNotEmpty);
    });

    test('múltiples conflictos → un ConflictAlert por cada uno', () {
      final result = engine.inferSchedule(
        baseFacts(value: 8),
        profile,
        conflictingMedications: ['MedA', 'MedB'],
      );

      expect(result.conflicts, hasLength(2));
      expect(
        result.conflicts.map((c) => c.conflictingMedicationName),
        containsAll(['MedA', 'MedB']),
      );
    });

    test('conflictos no afectan las sugerencias de horario', () {
      final withoutConflict = engine.inferSchedule(baseFacts(value: 8), profile);
      final withConflict = engine.inferSchedule(
        baseFacts(value: 8),
        profile,
        conflictingMedications: ['OtroMed'],
      );

      expect(withConflict.suggestions.length,
          equals(withoutConflict.suggestions.length));
    });

    test('R10 no aparece en appliedRules (es alerta, no regla de scheduling)', () {
      final result = engine.inferSchedule(
        baseFacts(value: 8),
        profile,
        conflictingMedications: ['OtroMed'],
      );

      // R10 NO está en traces (conflicts es campo separado)
      expect(result.appliedRules, isNot(contains('R10')));
    });
  });

  // ─── Trazabilidad ─────────────────────────────────────────────────────────

  group('Trazabilidad — InferenceTrace', () {
    test('cada SuggestedTime tiene ruleIds y explanation no vacíos', () {
      final result = engine.inferSchedule(baseFacts(value: 8), profile);

      for (final s in result.suggestions) {
        expect(s.ruleIds, isNotEmpty);
        expect(s.explanation, isNotEmpty);
      }
    });

    test('traces no está vacío para un resultado normal', () {
      final result = engine.inferSchedule(baseFacts(value: 8), profile);

      expect(result.traces, isNotEmpty);
    });

    test('appliedRules es derivado de traces (sin duplicados)', () {
      final result = engine.inferSchedule(
        baseFacts(
          type: FrequencyType.nTimesDay,
          value: 3,
          instructions: 'con comida',
        ),
        profile,
      );

      final fromTraces = result.traces.map((t) => t.ruleId).toSet().toList();
      expect(result.appliedRules.toSet(), equals(fromTraces.toSet()));
    });

    test('R01 + R03 coexisten en ruleIds de cada SuggestedTime', () {
      final result = engine.inferSchedule(
        baseFacts(
          type: FrequencyType.nTimesDay,
          value: 3,
          instructions: 'con comida',
        ),
        profile,
      );

      expect(result.suggestions.first.ruleIds, containsAll(['R02', 'R03']));
    });

    test('cada InferenceTrace tiene condition, conclusion y explanation', () {
      final result = engine.inferSchedule(baseFacts(value: 8), profile);

      for (final trace in result.traces) {
        expect(trace.ruleId, isNotEmpty);
        expect(trace.condition, isNotEmpty);
        expect(trace.conclusion, isNotEmpty);
        expect(trace.explanation, isNotEmpty);
      }
    });

    test('canCreateReminders es false cuando hay missingFields', () {
      final facts = TreatmentFacts(
        medicationName: 'Med',
        startDate: DateTime(2026, 1, 1),
      );
      expect(engine.inferSchedule(facts, profile).canCreateReminders, isFalse);
    });

    test('canCreateReminders es true con todos los campos presentes', () {
      expect(
        engine.inferSchedule(baseFacts(value: 8), profile).canCreateReminders,
        isTrue,
      );
    });
  });

  // ─── MedTime helpers ──────────────────────────────────────────────────────

  group('MedTime', () {
    test('fromMinutes envuelve pasada medianoche', () {
      expect(MedTime.fromMinutes(25 * 60), equals(const MedTime(1, 0)));
    });

    test('addMinutes cruza medianoche correctamente', () {
      expect(const MedTime(23, 30).addMinutes(60), equals(const MedTime(0, 30)));
    });

    test('format produce string con padding', () {
      expect(const MedTime(7, 5).format(), equals('07:05'));
      expect(const MedTime(0, 0).format(), equals('00:00'));
    });
  });
}
