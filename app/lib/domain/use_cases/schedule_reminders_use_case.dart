import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../entities/inference_result.dart';
import '../entities/med_time.dart';
import '../../infrastructure/database/app_database.dart';
import '../../infrastructure/database/daos/reminder_dao.dart';
import '../../infrastructure/notifications/notification_service.dart';

class ScheduleRemindersUseCase {
  final ReminderDao reminderDao;
  final NotificationService notificationService;

  const ScheduleRemindersUseCase({
    required this.reminderDao,
    required this.notificationService,
  });

  Future<void> execute({
    required String treatmentId,
    required String patientId,
    required String medicationName,
    required List<MedTime> confirmedTimes,
    required InferenceResult inferenceResult,
    required DateTime startDate,
  }) async {
    if (inferenceResult.isOnDemand) return;
    if (confirmedTimes.isEmpty) return;

    final snoozeWindow =
        inferenceResult.snoozePolicy?.window ?? const Duration(hours: 1);

    final companions = <RemindersTableCompanion>[];

    for (var i = 0; i < confirmedTimes.length; i++) {
      final time = confirmedTimes[i];
      final suggestion = i < inferenceResult.suggestions.length
          ? inferenceResult.suggestions[i]
          : null;

      final scheduledTime = DateTime(
        startDate.year, startDate.month, startDate.day,
        time.hour, time.minute,
      );

      final id = const Uuid().v4();
      final ruleId = (suggestion?.ruleIds.isNotEmpty ?? false)
          ? suggestion!.ruleIds.first
          : 'R01';

      companions.add(RemindersTableCompanion(
        id: Value(id),
        patientId: Value(patientId),
        treatmentId: Value(treatmentId),
        scheduledTime: Value(scheduledTime),
        deadlineTime: Value(scheduledTime.add(snoozeWindow)),
        status: const Value('pending'),
        snoozeCount: const Value(0),
        ruleId: Value(ruleId),
        ruleExplanation: Value(suggestion?.explanation ?? ''),
      ));

      final notifId = id.hashCode.abs() & 0x7FFFFFFF;
      await notificationService.scheduleDaily(
        id: notifId,
        medicationName: medicationName,
        scheduledTime: scheduledTime,
        body: suggestion?.explanation,
      );
    }

    await reminderDao.insertAll(companions);
  }
}
