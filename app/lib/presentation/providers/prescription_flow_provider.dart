import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/inference_result.dart';
import '../../domain/entities/parsed_prescription.dart';
import '../../domain/entities/patient_profile.dart';
import '../../domain/services/inference_engine.dart';
import '../../domain/use_cases/confirm_prescription_use_case.dart';
import '../../domain/use_cases/parse_prescription_use_case.dart';
import 'ai_providers.dart';
import 'database_providers.dart';

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

  const PrescriptionFlowReviewPrescription({
    required this.prescription,
    this.isAiParsed = false,
  });
}

class PrescriptionFlowReviewSchedule extends PrescriptionFlowState {
  final ParsedPrescription prescription;
  final InferenceResult inferenceResult;

  const PrescriptionFlowReviewSchedule({
    required this.prescription,
    required this.inferenceResult,
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

// ─── Notifier ─────────────────────────────────────────────────────────────────

class PrescriptionFlowNotifier extends StateNotifier<PrescriptionFlowState> {
  final ParsePrescriptionUseCase parseUseCase;
  final ConfirmPrescriptionUseCase confirmUseCase;
  final InferenceEngine _engine;

  PrescriptionFlowNotifier({
    required this.parseUseCase,
    required this.confirmUseCase,
  })  : _engine = const InferenceEngine(),
        super(const PrescriptionFlowIdle());

  /// Procesa la imagen vía OCR + IA y transiciona a la pantalla de revisión.
  Future<void> parseImage(File image) async {
    state = const PrescriptionFlowParsing();
    try {
      final result = await parseUseCase.execute(image);
      switch (result) {
        case FullParse(:final prescription):
          state = PrescriptionFlowReviewPrescription(
            prescription: prescription,
            isAiParsed: true,
          );
        case OcrOnly(:final rawText):
          state = PrescriptionFlowReviewPrescription(
            prescription: ParsedPrescription.empty(rawOcrText: rawText),
            isAiParsed: false,
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
    final facts = corrected.toTreatmentFacts(startDate: DateTime.now());
    final inferenceResult = _engine.inferSchedule(
      facts,
      PatientProfile.defaults,
    );
    state = PrescriptionFlowReviewSchedule(
      prescription: corrected,
      inferenceResult: inferenceResult,
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
      );
    }
  }

  /// Persiste el tratamiento confirmado. La programación de recordatorios
  /// ocurre en Fase 5 — aquí solo se guarda Medicamento + Tratamiento.
  Future<void> confirmAndSave({required DateTime startDate}) async {
    final current = state;
    if (current is! PrescriptionFlowReviewSchedule) return;

    state = const PrescriptionFlowSaving();
    try {
      final id = await confirmUseCase.execute(
        current.prescription,
        startDate: startDate,
      );
      state = PrescriptionFlowSaved(id);
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
  );
});
