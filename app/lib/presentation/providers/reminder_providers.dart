import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/use_cases/get_today_reminders_use_case.dart';
import '../../domain/use_cases/record_intake_use_case.dart';
import '../../domain/use_cases/schedule_reminders_use_case.dart';
import '../../domain/use_cases/snooze_reminder_use_case.dart';
import '../../infrastructure/notifications/notification_service.dart';
import 'database_providers.dart';

export '../../domain/use_cases/get_today_reminders_use_case.dart'
    show ReminderViewModel;

final notificationServiceProvider = Provider<NotificationService>(
  (_) => NotificationService.instance,
);

final scheduleRemindersUseCaseProvider = Provider<ScheduleRemindersUseCase>(
  (ref) => ScheduleRemindersUseCase(
    reminderDao: ref.watch(reminderDaoProvider),
    notificationService: ref.watch(notificationServiceProvider),
  ),
);

final getTodayRemindersUseCaseProvider = Provider<GetTodayRemindersUseCase>(
  (ref) => GetTodayRemindersUseCase(
    patientDao: ref.watch(patientDaoProvider),
    reminderDao: ref.watch(reminderDaoProvider),
    treatmentDao: ref.watch(treatmentDaoProvider),
    medicationDao: ref.watch(medicationDaoProvider),
  ),
);

final todayRemindersProvider = FutureProvider<List<ReminderViewModel>>(
  (ref) => ref.read(getTodayRemindersUseCaseProvider).execute(),
);

final recordIntakeUseCaseProvider = Provider<RecordIntakeUseCase>(
  (ref) => RecordIntakeUseCase(
    reminderDao: ref.watch(reminderDaoProvider),
    intakeDao: ref.watch(intakeDaoProvider),
    notificationService: ref.watch(notificationServiceProvider),
  ),
);

final snoozeReminderUseCaseProvider = Provider<SnoozeReminderUseCase>(
  (ref) => SnoozeReminderUseCase(
    reminderDao: ref.watch(reminderDaoProvider),
    notificationService: ref.watch(notificationServiceProvider),
  ),
);
