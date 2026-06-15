import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../infrastructure/database/app_database.dart';
import '../../domain/use_cases/get_treatment_history_use_case.dart';
import 'database_providers.dart';

export '../../domain/use_cases/get_treatment_history_use_case.dart'
    show TreatmentHistoryViewModel;

class ActiveTreatmentFact {
  final String treatmentId;
  final String medicationName;
  final List<String> appliedRuleIds;

  const ActiveTreatmentFact({
    required this.treatmentId,
    required this.medicationName,
    required this.appliedRuleIds,
  });
}

final getTreatmentHistoryUseCaseProvider =
    Provider<GetTreatmentHistoryUseCase>((ref) => GetTreatmentHistoryUseCase(
          patientDao: ref.watch(patientDaoProvider),
          treatmentDao: ref.watch(treatmentDaoProvider),
          medicationDao: ref.watch(medicationDaoProvider),
          reminderDao: ref.watch(reminderDaoProvider),
          intakeDao: ref.watch(intakeDaoProvider),
        ));

final treatmentHistoryProvider =
    FutureProvider<List<TreatmentHistoryViewModel>>(
  (ref) => ref.read(getTreatmentHistoryUseCaseProvider).execute(),
);

final activeFactsProvider = FutureProvider<List<ActiveTreatmentFact>>(
  (ref) async {
    final history =
        await ref.read(getTreatmentHistoryUseCaseProvider).execute();
    final active =
        history.where((h) => h.treatment.status == 'active').toList();

    final result = <ActiveTreatmentFact>[];
    for (final h in active) {
      final reminders =
          await ref.read(reminderDaoProvider).getByTreatment(h.treatment.id);
      final ruleIds = reminders
          .map((r) => r.ruleId)
          .where((id) => id.isNotEmpty)
          .toSet()
          .toList()
        ..sort();
      result.add(ActiveTreatmentFact(
        treatmentId: h.treatment.id,
        medicationName: h.medicationName,
        appliedRuleIds: ruleIds,
      ));
    }
    return result;
  },
);

final remindersByTreatmentProvider =
    FutureProvider.family<List<RemindersTableData>, String>(
  (ref, treatmentId) =>
      ref.read(reminderDaoProvider).getByTreatment(treatmentId),
);

final intakesByTreatmentProvider =
    FutureProvider.family<List<IntakesTableData>, String>(
  (ref, treatmentId) =>
      ref.read(intakeDaoProvider).getByTreatment(treatmentId),
);
