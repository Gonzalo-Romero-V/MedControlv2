import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final NotificationService instance = NotificationService._();
  NotificationService._() : _plugin = FlutterLocalNotificationsPlugin();

  static const _channelId = 'med_control_reminders';
  static const _channelName = 'Recordatorios de medicamentos';

  final FlutterLocalNotificationsPlugin _plugin;

  Future<void> initialize() async {
    tz.initializeTimeZones();
    // MVP: hardcoded to Argentina; Phase 6 can detect device timezone
    tz.setLocalLocation(tz.getLocation('America/Argentina/Buenos_Aires'));

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    await _plugin.initialize(
      const InitializationSettings(android: android, iOS: ios),
    );

    final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.createNotificationChannel(
      const AndroidNotificationChannel(
        _channelId,
        _channelName,
        description: 'Alertas de hora de medicamentos',
        importance: Importance.high,
      ),
    );
  }

  /// Programa una notificación que se repite diariamente a la misma hora.
  Future<void> scheduleDaily({
    required int id,
    required String medicationName,
    required DateTime scheduledTime,
    String? body,
  }) async {
    final tzTime = tz.TZDateTime(
      tz.local,
      scheduledTime.year,
      scheduledTime.month,
      scheduledTime.day,
      scheduledTime.hour,
      scheduledTime.minute,
    );
    await _plugin.zonedSchedule(
      id,
      medicationName,
      body ?? 'Es hora de tomar tu medicamento.',
      tzTime,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  /// Programa una notificación que se dispara exactamente una vez (para snooze).
  Future<void> scheduleOnce({
    required int id,
    required String medicationName,
    required DateTime scheduledTime,
    String? body,
  }) async {
    final tzTime = tz.TZDateTime.from(scheduledTime, tz.local);
    await _plugin.zonedSchedule(
      id,
      medicationName,
      body ?? 'Recordatorio pospuesto.',
      tzTime,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> cancelReminder(int id) => _plugin.cancel(id);
  Future<void> cancelAll() => _plugin.cancelAll();
}
