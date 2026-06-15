import '../../infrastructure/database/app_database.dart';
import '../../infrastructure/database/daos/reminder_dao.dart';
import '../../infrastructure/notifications/notification_service.dart';

class SnoozeReminderUseCase {
  final ReminderDao reminderDao;
  final NotificationService notificationService;

  static const _maxSnoozes = 3;
  static const _snoozeDuration = Duration(minutes: 30);

  const SnoozeReminderUseCase({
    required this.reminderDao,
    required this.notificationService,
  });

  /// Returns true if snooze was applied.
  /// Returns false when: medicamento crítico, o ya se alcanzó el máximo de postposiciones.
  /// [isAlertMode] debe coincidir con el modo del recordatorio original para que la
  /// notificación pospuesta tenga el mismo comportamiento (pantalla de alarma o discreto).
  Future<bool> execute({
    required RemindersTableData reminder,
    required bool isCritical,
    required String medicationName,
    bool isAlertMode = true,
  }) async {
    if (isCritical) return false;
    if (reminder.snoozeCount >= _maxSnoozes) return false;

    final newTime = DateTime.now().add(_snoozeDuration);
    final notifId = reminder.id.hashCode.abs() & 0x7FFFFFFF;

    await notificationService.cancelReminder(notifId);
    await notificationService.scheduleOnce(
      id: notifId,
      reminderId: reminder.id,
      medicationName: medicationName,
      scheduledTime: newTime,
      body: 'Recordatorio pospuesto (${reminder.snoozeCount + 1}/$_maxSnoozes).',
      isCritical: isCritical,
      isAlertMode: isAlertMode,
    );

    await reminderDao.updateStatus(
      reminder.id,
      'snoozed',
      snoozeCount: reminder.snoozeCount + 1,
    );

    return true;
  }
}
