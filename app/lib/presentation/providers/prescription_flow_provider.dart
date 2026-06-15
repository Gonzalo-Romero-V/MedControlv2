import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/accessibility_config.dart';
import '../../domain/entities/inference_result.dart';
import '../../domain/entities/med_time.dart';
import '../../domain/entities/parsed_prescription.dart';
import '../../domain/entities/patient_profile.dart';
import '../../domain/services/inference_engine.dart';
import '../../domain/use_cases/confirm_prescription_use_case.dart'
    show ConfirmPrescriptionUseCase, DuplicateMedicationException;
import '../../domain/use_cases/parse_prescription_use_case.dart';
import '../../domain/use_cases/schedule_reminders_use_case.dart';
import 'ai_providers.dart';
import 'database_providers.dart';
import 'patient_providers.dart';
import 'reminder_providers.dart';

// ─── Estados del flujo ────────────────────────────────────────────────────────

sealed class PrescriptionFlowState {
  const PrescriptionFlowState();
}

class PrescriptionFlowIdle extends PrescriptionFlowState {
  const PrescriptionFlowIdle();
}

class PrescriptionFlowParsing extends PrescriptionFlowState {
  const PrescriptionFlowParsing();
}

class PrescriptionFlowReviewPrescription extends PrescriptionFlowState {
  final ParsedPrescription prescription;
  final bool isAiParsed;
  /// true = Cloud Vision hizo el OCR; false = ML Kit on-device.
  final bool usedCloudVision;

  const PrescriptionFlowReviewPrescription({
    required this.prescription,
    this.isAiParsed = false,
    this.usedCloudVision = false,
  });
}

class PrescriptionFlowReviewSchedule extends PrescriptionFlowState {
  final ParsedPrescription prescription;
  final InferenceResult inferenceResult;
  final bool usedCloudVision;

  const PrescriptionFlowReviewSchedule({
    required this.prescription,
    required this.inferenceResult,
    this.usedCloudVision = false,
  });
}

class PrescriptionFlowSaving extends PrescriptionFlowState {
  const PrescriptionFlowSaving();
}

class PrescriptionFlowSaved extends PrescriptionFlowState {
  final String treatmentId;
  const PrescriptionFlowSaved(this.treatmentId);
}

class PrescriptionFlowError extends PrescriptionFlowState {
  final String message;
  final bool allowManualEntry;
  const PrescriptionFlowError(this.message, {this.allowManualEntry = false});
}

/// The patient already has an active/suspended treatment for the same medication.
/// The user must explicitly confirm before proceeding.
class PrescriptionFlowDuplicateConflict extends PrescriptionFlowState {
  final String conflictingMedName;
  final PrescriptionFlowReviewSchedule scheduleState;
  final DateTime startDate;
  final List<TimeOfDay> confirmedTimes;
  const PrescriptionFlowDuplicateConflict({
    required this.conflictingMedName,
    required this.scheduleState,
    required this.startDate,
    required this.confirmedTimes,
  });
}

// ─── Notifier ─────────────────────────────────────────────────────────────────

class PrescriptionFlowNotifier extends StateNotifier<PrescriptionFlowState> {
  final ParsePrescriptionUseCase parseUseCase;
  final ConfirmPrescriptionUseCase confirmUseCase;
  final ScheduleRemindersUseCase scheduleRemindersUseCase;
  final PatientProfile patientProfile;
  final NotificationMode notificationMode;
  final InferenceEngine _engine;

  PrescriptionFlowNotifier({
    required this.parseUseCase,
    required this.confirmUseCase,
    required this.scheduleRemindersUseCase,
    required this.patientProfile,
    this.notificationMode = NotificationMode.active,
  })  : _engine = const InferenceEngine(),
        super(const PrescriptionFlowIdle());

  /// Procesa la imagen vía OCR + IA y transiciona a la pantalla de revisión.
  Future<void> parseImage(File image) async {
    state = const PrescriptionFlowParsing();
    try {
      final result = await parseUseCase.execute(image);
      switch (result) {
        case FullParse(:final prescription, :final usedCloudVision):
          state = PrescriptionFlowReviewPrescription(
            prescription: prescription,
            isAiParsed: true,
            usedCloudVision: usedCloudVision,
          );
        case OcrOnly(:final rawText, :final usedCloudVision):
          state = PrescriptionFlowReviewPrescription(
            prescription: ParsedPrescription.empty(rawOcrText: rawText),
            isAiParsed: false,
            usedCloudVision: usedCloudVision,
          );
        case ParseFailure(:final message):
          state = PrescriptionFlowError(
            message,
            allowManualEntry: true,
          );
      }
    } catch (e) {
      state = PrescriptionFlowError(
        'Error inesperado al procesar la imagen.',
        allowManualEntry: true,
      );
    }
  }

  /// Inicia el flujo de ingreso manual sin imagen.
  void useManualEntry() {
    state = const PrescriptionFlowReviewPrescription(
      prescription: ParsedPrescription(
        rawOcrText: '',
        source: PrescriptionSource.mlkitManual,
      ),
      isAiParsed: false,
    );
  }

  /// Acepta la receta revisada/corregida, corre el motor de inferencia
  /// y transiciona a la revisión de horarios.
  void submitReviewedPrescription(ParsedPrescription corrected) {
    final prev = state;
    final usedCloudVision =
        prev is PrescriptionFlowReviewPrescription ? prev.usedCloudVision : false;
    final facts = corrected.toTreatmentFacts(startDate: DateTime.now());
    final inferenceResult = _engine.inferSchedule(facts, patientProfile);
    state = PrescriptionFlowReviewSchedule(
      prescription: corrected,
      inferenceResult: inferenceResult,
      usedCloudVision: usedCloudVision,
    );
  }

  /// Vuelve a la revisión de la receta desde la revisión de horarios.
  void backToReviewPrescription() {
    final current = state;
    if (current is PrescriptionFlowReviewSchedule) {
      state = PrescriptionFlowReviewPrescription(
        prescription: current.prescription,
        isAiParsed:
            current.prescription.source == PrescriptionSource.cloudVisionGemini,
        usedCloudVision: current.usedCloudVision,
      );
    }
  }

  /// Persiste el tratamiento y programa los recordatorios locales.
  /// Set [forceOverride] = true to bypass a duplicate-medication conflict.
  Future<void> confirmAndSave({
    required DateTime startDate,
    List<TimeOfDay> confirmedTimes = const [],
    bool forceOverride = false,
  }) async {
    final current = state is PrescriptionFlowDuplicateConflict
        ? (state as PrescriptionFlowDuplicateConflict).scheduleState
        : state;
    if (current is! PrescriptionFlowReviewSchedule) return;

    state = const PrescriptionFlowSaving();
    try {
      final (:treatmentId, :patientId) = await confirmUseCase.execute(
        current.prescription,
        startDate: startDate,
        forceOverride: forceOverride,
      );

      final medTimes =
          confirmedTimes.map((t) => MedTime(t.hour, t.minute)).toList();

      await scheduleRemindersUseCase.execute(
        treatmentId: treatmentId,
        patientId: patientId,
        medicationName:
            current.prescription.medicationName ?? 'Medicamento',
        confirmedTimes: medTimes,
        inferenceResult: current.inferenceResult,
        startDate: startDate,
        useAlertMode: notificationMode == NotificationMode.active,
      );

      state = PrescriptionFlowSaved(treatmentId);
    } on DuplicateMedicationException catch (e) {
      state = PrescriptionFlowDuplicateConflict(
        conflictingMedName: e.medicationName,
        scheduleState: current,
        startDate: startDate,
        confirmedTimes: confirmedTimes,
      );
    } catch (e) {
      state = PrescriptionFlowError('Error al guardar el tratamiento: $e');
    }
  }

  void reset() => state = const PrescriptionFlowIdle();
}

// ─── Provider ─────────────────────────────────────────────────────────────────

final confirmPrescriptionUseCaseProvider =
    Provider<ConfirmPrescriptionUseCase>((ref) {
  return ConfirmPrescriptionUseCase(
    patientDao: ref.watch(patientDaoProvider),
    medicationDao: ref.watch(medicationDaoProvider),
    treatmentDao: ref.watch(treatmentDaoProvider),
  );
});

final prescriptionFlowProvider =
    StateNotifierProvider<PrescriptionFlowNotifier, PrescriptionFlowState>(
        (ref) {
  return PrescriptionFlowNotifier(
    parseUseCase: ref.watch(parsePrescriptionUseCaseProvider),
    confirmUseCase: ref.watch(confirmPrescriptionUseCaseProvider),
    scheduleRemindersUseCase: ref.watch(scheduleRemindersUseCaseProvider),
    patientProfile: ref.watch(patientProfileProvider),
    notificationMode: ref.watch(accessibilityConfigProvider).notificationMode,
  );
});
