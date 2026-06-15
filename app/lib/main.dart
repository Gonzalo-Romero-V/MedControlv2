import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'domain/use_cases/record_intake_use_case.dart';
import 'domain/use_cases/snooze_reminder_use_case.dart';
import 'infrastructure/database/app_database.dart';
import 'infrastructure/notifications/notification_service.dart';
import 'infrastructure/notifications/pending_alarm_notifier.dart';
import 'presentation/app.dart';

/// Handles notification action buttons (DISCRETO mode) when the app is killed or in background.
/// Must be a top-level function annotated with @pragma('vm:entry-point').
@pragma('vm:entry-point')
Future<void> _onNotificationBackgroundAction(NotificationResponse response) async {
  // Background isolates need Flutter bindings and notification service init.
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.instance.initialize();

  final parsed = NotificationService.parsePayload(response.payload);
  if (parsed == null) return;
  final actionId = response.actionId;
  if (actionId == null) return;

  // Open an independent DB connection for this background isolate.
  final db = AppDatabase();
  try {
    final reminder = await db.reminderDao.getById(parsed.reminderId);
    if (reminder == null) return;

    final notifService = NotificationService.instance;
    switch (actionId) {
      case kActionMarkTaken:
        await RecordIntakeUseCase(
          reminderDao: db.reminderDao,
          intakeDao: db.intakeDao,
          notificationService: notifService,
        ).execute(reminder: reminder, taken: true);
      case kActionSkip:
        await RecordIntakeUseCase(
          reminderDao: db.reminderDao,
          intakeDao: db.intakeDao,
          notificationService: notifService,
        ).execute(reminder: reminder, taken: false);
      case kActionSnooze:
        await SnoozeReminderUseCase(
          reminderDao: db.reminderDao,
          notificationService: notifService,
        ).execute(
          reminder: reminder,
          isCritical: parsed.isCritical,
          medicationName: parsed.medicationName,
          isAlertMode: parsed.isAlertMode,
        );
    }
  } finally {
    await db.close();
  }
}

/// Handles notification tap (or full-screen intent launch) while the app is in the foreground.
/// For ACTIVO mode, routes the response to [pendingAlarmNotifier] so the widget tree can
/// navigate to [AlarmScreen].
void _onNotificationForegroundAction(NotificationResponse response) {
  // Action button taps in DISCRETO mode with showsUserInterface:true land here.
  // SKIP is the only one — it needs the app open. Just ignoring it here is fine
  // because the AlarmScreen handles its own "No puedo tomarlo" action directly.
  if (response.actionId != null) return;

  final parsed = NotificationService.parsePayload(response.payload);
  if (parsed == null || !parsed.isAlertMode) return;

  // Signal the widget tree to show the alarm screen.
  pendingAlarmNotifier.value = response;
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  await initializeDateFormatting('es', null);
  await NotificationService.instance.initialize(
    onForegroundAction: _onNotificationForegroundAction,
    onBackgroundAction: _onNotificationBackgroundAction,
  );

  // If the app was killed and an ACTIVO alarm fired, Android launches us via
  // the full-screen intent. Pre-populate the notifier so _MainShell navigates
  // to AlarmScreen as soon as the widget tree is ready.
  final launchDetails = await NotificationService.instance.getNotificationLaunchDetails();
  if (launchDetails?.didNotificationLaunchApp == true) {
    final response = launchDetails!.notificationResponse;
    if (response?.actionId == null) {
      final parsed = NotificationService.parsePayload(response?.payload);
      if (parsed != null && parsed.isAlertMode) {
        pendingAlarmNotifier.value = response;
      }
    }
  }

  runApp(const ProviderScope(child: MedControlApp()));
}
