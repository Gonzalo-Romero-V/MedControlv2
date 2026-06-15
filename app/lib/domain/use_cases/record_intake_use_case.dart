import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../infrastructure/database/app_database.dart';
import '../../infrastructure/database/daos/intake_dao.dart';
import '../../infrastructure/database/daos/reminder_dao.dart';
import '../../infrastructure/notifications/notification_service.dart';

class RecordIntakeUseCase {
  final ReminderDao reminderDao;
  final IntakeDao intakeDao;
  final NotificationService notificationService;

  const RecordIntakeUseCase({
    required this.reminderDao,
    required this.intakeDao,
    required this.notificationService,
  });

  /// [taken] = true → tomé el medicamento; false → no puedo/omití.
  Future<void> execute({
    required RemindersTableData reminder,
    required bool taken,
    DateTime? actualTime,
  }) async {
    final now = actualTime ?? DateTime.now();
    final minutesLate = now.isAfter(reminder.scheduledTime)
        ? now.difference(reminder.scheduledTime).inMinutes
        : 0;

    final result = taken
        ? (minutesLate > 15 ? 'taken_late' : 'taken')
        : 'skipped';

    await intakeDao.insertIntake(IntakesTableCompanion(
      id: Value(const Uuid().v4()),
      reminderId: Value(reminder.id),
      result: Value(result),
      actualTime: Value(now),
      minutesLate: minutesLate > 0 ? Value(minutesLate) : const Value.absent(),
      recordedAt: Value(now),
    ));

    await reminderDao.updateStatus(reminder.id, taken ? 'taken' : 'closed');

    final notifId = reminder.id.hashCode.abs() & 0x7FFFFFFF;
    await notificationService.cancelReminder(notifId);
  }
}
