import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
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
    bool useAlertMode = true,
  }) async {
    if (inferenceResult.isOnDemand) return;
    if (confirmedTimes.isEmpty) return;

    final snoozeWindow =
        inferenceResult.snoozePolicy?.window ?? const Duration(hours: 1);

    final isCritical = inferenceResult.snoozePolicy?.isCritical ?? false;

    final companions = <RemindersTableCompanion>[];
    final notifSchedules = <({int notifId, String reminderId, DateTime scheduledTime, String? body})>[];

    for (var i = 0; i < confirmedTimes.length; i++) {
      final time = confirmedTimes[i];
      final suggestion = i < inferenceResult.suggestions.length
          ? inferenceResult.suggestions[i]
          : null;

      // If the computed time is already in the past (e.g. user saved at 23:59
      // with a suggested breakfast time of 07:00), advance to the next day so
      // the first notification fires at the correct upcoming occurrence.
      var scheduledTime = DateTime(
        startDate.year, startDate.month, startDate.day,
        time.hour, time.minute,
      );
      if (scheduledTime.isBefore(DateTime.now())) {
        scheduledTime = scheduledTime.add(const Duration(days: 1));
      }

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

      notifSchedules.add((
        notifId: id.hashCode.abs() & 0x7FFFFFFF,
        reminderId: id,
        scheduledTime: scheduledTime,
        body: suggestion?.explanation,
      ));
    }

    // Persist reminders first — always succeeds unless the DB is broken
    await reminderDao.insertAll(companions);

    // Schedule notifications — graceful degradation: a failed notification
    // does not cancel the saved treatment or reminder records
    for (final n in notifSchedules) {
      try {
        await notificationService.scheduleDaily(
          id: n.notifId,
          reminderId: n.reminderId,
          medicationName: medicationName,
          scheduledTime: n.scheduledTime,
          body: n.body,
          useAlertMode: useAlertMode,
          isCritical: isCritical,
        );
        debugPrint(
          '[Notifications] Scheduled notif ${n.notifId} '
          'for ${n.scheduledTime.toIso8601String()} '
          '(alertMode=$useAlertMode, critical=$isCritical)',
        );
      } catch (e, st) {
        debugPrint('[Notifications] FAILED notif ${n.notifId}: $e\n$st');
      }
    }
  }
}
