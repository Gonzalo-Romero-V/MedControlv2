import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/prescription_flow_provider.dart';
import 'prescription_capture_screen.dart';
import 'prescription_review_screen.dart';
import 'schedule_review_screen.dart';

/// Pantalla contenedora del flujo de registro de receta.
/// Renderiza la sub-pantalla correcta según el estado del PrescriptionFlowNotifier.
/// Se pushea sobre el stack de navegación desde TodayRemindersScreen.
class PrescriptionFlowScreen extends ConsumerWidget {
  const PrescriptionFlowScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(prescriptionFlowProvider);

    ref.listen<PrescriptionFlowState>(prescriptionFlowProvider, (prev, next) {
      if (next is PrescriptionFlowSaved) {
        _showSavedAndPop(context, ref);
      } else if (next is PrescriptionFlowError && prev is PrescriptionFlowSaving) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.message),
            backgroundColor: Colors.red.shade700,
            duration: const Duration(seconds: 6),
          ),
        );
      } else if (next is PrescriptionFlowDuplicateConflict) {
        _showDuplicateDialog(context, ref, next);
      }
    });

    return switch (state) {
      PrescriptionFlowIdle() ||
      PrescriptionFlowParsing() ||
      PrescriptionFlowError() =>
        const PrescriptionCaptureScreen(),
      PrescriptionFlowReviewPrescription(
        :final prescription,
        :final isAiParsed,
        :final usedCloudVision,
      ) =>
        PrescriptionReviewScreen(
          prescription: prescription,
          isAiParsed: isAiParsed,
          usedCloudVision: usedCloudVision,
        ),
      PrescriptionFlowReviewSchedule(
        :final prescription,
        :final inferenceResult
      ) =>
        ScheduleReviewScreen(
          prescription: prescription,
          inferenceResult: inferenceResult,
        ),
      PrescriptionFlowDuplicateConflict(:final scheduleState) =>
        ScheduleReviewScreen(
          prescription: scheduleState.prescription,
          inferenceResult: scheduleState.inferenceResult,
        ),
      PrescriptionFlowSaving() || PrescriptionFlowSaved() =>
        const _SavingScreen(),
    };
  }

  Future<void> _showDuplicateDialog(
    BuildContext context,
    WidgetRef ref,
    PrescriptionFlowDuplicateConflict conflict,
  ) async {
    bool confirmed = false;
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => _DuplicateConfirmDialog(
        medicationName: conflict.conflictingMedName,
        onConfirm: () { confirmed = true; Navigator.of(ctx).pop(); },
        onCancel: () {
          Navigator.of(ctx).pop();
          // Restore to schedule review so the user can go back or cancel
          ref.read(prescriptionFlowProvider.notifier).backToReviewPrescription();
        },
      ),
    );
    if (confirmed) {
      ref.read(prescriptionFlowProvider.notifier).confirmAndSave(
        startDate: conflict.startDate,
        confirmedTimes: conflict.confirmedTimes,
        forceOverride: true,
      );
    }
  }

  void _showSavedAndPop(BuildContext context, WidgetRef ref) {
    ref.read(prescriptionFlowProvider.notifier).reset();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 8),
            Text('Tratamiento guardado correctamente'),
          ],
        ),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 3),
      ),
    );
    Navigator.of(context).pop();
  }
}

class _DuplicateConfirmDialog extends StatefulWidget {
  final String medicationName;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;
  const _DuplicateConfirmDialog({
    required this.medicationName,
    required this.onConfirm,
    required this.onCancel,
  });

  @override
  State<_DuplicateConfirmDialog> createState() =>
      _DuplicateConfirmDialogState();
}

class _DuplicateConfirmDialogState extends State<_DuplicateConfirmDialog> {
  bool _confirmed = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      icon: Icon(Icons.warning_amber_rounded,
          color: Colors.orange.shade700, size: 36),
      title: const Text('Tratamiento duplicado'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ya tenés un tratamiento activo de "${widget.medicationName}". '
            'Tomar dos tratamientos del mismo medicamento puede ser peligroso. '
            'Esta decisión debe tomarla tu médico.',
            style: const TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 16),
          CheckboxListTile(
            value: _confirmed,
            onChanged: (v) => setState(() => _confirmed = v ?? false),
            controlAffinity: ListTileControlAffinity.leading,
            title: const Text(
              'Entiendo el riesgo y mi médico lo indicó expresamente.',
              style: TextStyle(fontSize: 13),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: widget.onCancel,
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _confirmed ? widget.onConfirm : null,
          child: const Text('Registrar igual'),
        ),
      ],
    );
  }
}

class _SavingScreen extends StatelessWidget {
  const _SavingScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Guardando…'),
        automaticallyImplyLeading: false,
      ),
      body: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 24),
            Text('Guardando el tratamiento…'),
          ],
        ),
      ),
    );
  }
}
