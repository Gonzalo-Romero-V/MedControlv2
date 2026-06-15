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
      }
    });

    return switch (state) {
      PrescriptionFlowIdle() ||
      PrescriptionFlowParsing() ||
      PrescriptionFlowError() =>
        const PrescriptionCaptureScreen(),
      PrescriptionFlowReviewPrescription(
        :final prescription,
        :final isAiParsed
      ) =>
        PrescriptionReviewScreen(
          prescription: prescription,
          isAiParsed: isAiParsed,
        ),
      PrescriptionFlowReviewSchedule(
        :final prescription,
        :final inferenceResult
      ) =>
        ScheduleReviewScreen(
          prescription: prescription,
          inferenceResult: inferenceResult,
        ),
      PrescriptionFlowSaving() || PrescriptionFlowSaved() =>
        const _SavingScreen(),
    };
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
