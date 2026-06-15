import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

// Action IDs — used in notification buttons (DISCRETO mode) and background handler
const kActionMarkTaken = 'MARK_TAKEN';
const kActionSnooze    = 'SNOOZE';
const kActionSkip      = 'SKIP';

// Payload separator — avoids splitting medication names that contain '|'
const _sep = '||';

class NotificationService {
  static final NotificationService instance = NotificationService._();
  NotificationService._() : _plugin = FlutterLocalNotificationsPlugin();

  static const _alertChannelId   = 'med_control_alert';
  static const _alertChannelName = 'Alerta activa de medicamentos';
  static const _subtleChannelId   = 'med_control_subtle';
  static const _subtleChannelName = 'Recordatorio discreto';

  final FlutterLocalNotificationsPlugin _plugin;

  Future<void> initialize({
    /// Called when the user taps the notification or an action while the app is in the foreground.
    void Function(NotificationResponse)? onForegroundAction,
    /// Top-level function annotated @pragma('vm:entry-point') for background/killed-app handling.
    DidReceiveBackgroundNotificationResponseCallback? onBackgroundAction,
  }) async {
    tz.initializeTimeZones();
    try {
      final tzInfo = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(tzInfo.identifier));
    } catch (_) {
      // Fallback: primary deployment region; only reached if platform channel fails
      tz.setLocalLocation(tz.getLocation('America/Argentina/Buenos_Aires'));
    }

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    await _plugin.initialize(
      const InitializationSettings(android: android, iOS: ios),
      onDidReceiveNotificationResponse: onForegroundAction,
      onDidReceiveBackgroundNotificationResponse: onBackgroundAction,
    );

    final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    await androidPlugin?.createNotificationChannel(
      const AndroidNotificationChannel(
        _alertChannelId,
        _alertChannelName,
        description: 'Sonido + vibración fuerte. Abre pantalla de alarma aunque el teléfono esté bloqueado.',
        importance: Importance.max,
        enableVibration: true,
        playSound: true,
      ),
    );

    await androidPlugin?.createNotificationChannel(
      const AndroidNotificationChannel(
        _subtleChannelId,
        _subtleChannelName,
        description: 'Sin sonido, solo vibración suave.',
        importance: Importance.defaultImportance,
        enableVibration: true,
        playSound: false,
      ),
    );

    await androidPlugin?.requestNotificationsPermission();

    // Android 12 (API 31-32): SCHEDULE_EXACT_ALARM is declared but NOT auto-granted —
    // the user must enable "Alarms & reminders" in system settings.
    final canExact = await androidPlugin?.canScheduleExactNotifications() ?? true;
    if (!canExact) {
      await androidPlugin?.requestExactAlarmsPermission();
    }
  }

  /// Returns the notification that caused the app to launch (killed → alarm fired).
  /// Returns null if the app was opened normally.
  Future<NotificationAppLaunchDetails?> getNotificationLaunchDetails() =>
      _plugin.getNotificationAppLaunchDetails();

  /// Solicita el permiso USE_FULL_SCREEN_INTENT (Android 14+ / API 34+).
  ///
  /// Con este permiso concedido, las alarmas en modo ACTIVO emergen sobre cualquier
  /// app aunque la pantalla esté encendida — igual que una llamada entrante.
  ///
  /// * En Android ≤ 13: devuelve `true` inmediatamente (permiso auto-concedido).
  /// * En Android 14+: abre la pantalla de sistema para que el usuario lo conceda.
  ///   Devuelve `true` si fue concedido, `false` si el usuario rechazó.
  Future<bool> requestFullScreenIntentPermission() async {
    final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    return await androidPlugin?.requestFullScreenIntentPermission() ?? true;
  }

  // ─── Payload encoding ──────────────────────────────────────────────────────

  /// Encodes the reminder payload so the background handler and alarm screen can decode it.
  /// Format: reminderId||medicationName||isCritical||isAlertMode
  static String buildPayload(
    String reminderId,
    String medicationName,
    bool isCritical,
    bool isAlertMode,
  ) =>
      '$reminderId$_sep$medicationName$_sep$isCritical$_sep$isAlertMode';

  /// Decodes payload built by [buildPayload]. Returns null if malformed.
  static ({
    String reminderId,
    String medicationName,
    bool isCritical,
    bool isAlertMode,
  })? parsePayload(String? raw) {
    if (raw == null) return null;
    final parts = raw.split(_sep);
    if (parts.length < 4) return null;
    return (
      reminderId: parts[0],
      medicationName: parts[1],
      isCritical: parts[2] == 'true',
      isAlertMode: parts[3] == 'true',
    );
  }

  // ─── Scheduling ────────────────────────────────────────────────────────────

  /// Programa una notificación que se repite diariamente a la misma hora.
  ///
  /// [useAlertMode] true  → ACTIVO: abre [AlarmScreen] al dispararse (pantalla completa).
  ///               false → DISCRETO: notificación pequeña con botones de acción.
  Future<void> scheduleDaily({
    required int id,
    required String reminderId,
    required String medicationName,
    required DateTime scheduledTime,
    String? body,
    bool useAlertMode = true,
    bool isCritical = false,
  }) async {
    final channelId   = useAlertMode ? _alertChannelId   : _subtleChannelId;
    final channelName = useAlertMode ? _alertChannelName : _subtleChannelName;
    final payload     = buildPayload(reminderId, medicationName, isCritical, useAlertMode);

    final tzTime = tz.TZDateTime(
      tz.local,
      scheduledTime.year,
      scheduledTime.month,
      scheduledTime.day,
      scheduledTime.hour,
      scheduledTime.minute,
    );

    // ACTIVO: sin botones — la pantalla de alarma tiene las acciones grandes.
    // DISCRETO: con botones de acción para manejar desde la sombra de notificaciones.
    final actions = useAlertMode ? const <AndroidNotificationAction>[] : _buildActions(isCritical: isCritical);

    await _plugin.zonedSchedule(
      id,
      medicationName,
      body ?? 'Es hora de tomar tu medicamento.',
      tzTime,
      NotificationDetails(
        android: AndroidNotificationDetails(
          channelId,
          channelName,
          importance: useAlertMode ? Importance.max : Importance.defaultImportance,
          priority: useAlertMode ? Priority.max : Priority.defaultPriority,
          enableVibration: true,
          playSound: useAlertMode,
          fullScreenIntent: useAlertMode,
          actions: actions,
        ),
        iOS: DarwinNotificationDetails(
          presentSound: useAlertMode,
          presentBadge: true,
          presentAlert: true,
        ),
      ),
      payload: payload,
      androidScheduleMode: await _resolveScheduleMode(useAlarmClock: useAlertMode),
      matchDateTimeComponents: DateTimeComponents.time,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  /// Programa una notificación que se dispara exactamente una vez (para snooze).
  /// [isAlertMode] hereda el modo del recordatorio original.
  Future<void> scheduleOnce({
    required int id,
    required String reminderId,
    required String medicationName,
    required DateTime scheduledTime,
    String? body,
    bool isCritical = false,
    bool isAlertMode = true,
  }) async {
    final payload  = buildPayload(reminderId, medicationName, isCritical, isAlertMode);
    final tzTime   = tz.TZDateTime.from(scheduledTime, tz.local);
    final actions  = isAlertMode ? const <AndroidNotificationAction>[] : _buildActions(isCritical: isCritical);
    final channelId   = isAlertMode ? _alertChannelId   : _subtleChannelId;
    final channelName = isAlertMode ? _alertChannelName : _subtleChannelName;

    await _plugin.zonedSchedule(
      id,
      medicationName,
      body ?? 'Recordatorio pospuesto.',
      tzTime,
      NotificationDetails(
        android: AndroidNotificationDetails(
          channelId,
          channelName,
          importance: isAlertMode ? Importance.max : Importance.defaultImportance,
          priority: isAlertMode ? Priority.max : Priority.defaultPriority,
          fullScreenIntent: isAlertMode,
          actions: actions,
        ),
        iOS: const DarwinNotificationDetails(),
      ),
      payload: payload,
      androidScheduleMode: await _resolveScheduleMode(useAlarmClock: isAlertMode),
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> cancelReminder(int id) => _plugin.cancel(id);
  Future<void> cancelAll() => _plugin.cancelAll();

  // Selects alarmClock (alert) or exactAllowWhileIdle (subtle).
  // Falls back to inexact if SCHEDULE_EXACT_ALARM wasn't granted (Android 12 / API 31-32).
  Future<AndroidScheduleMode> _resolveScheduleMode({
    required bool useAlarmClock,
  }) async {
    final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    final canExact = await androidPlugin?.canScheduleExactNotifications() ?? true;
    if (!canExact) return AndroidScheduleMode.inexact;
    return useAlarmClock
        ? AndroidScheduleMode.alarmClock
        : AndroidScheduleMode.exactAllowWhileIdle;
  }

  static List<AndroidNotificationAction> _buildActions({required bool isCritical}) {
    if (isCritical) {
      return const [
        AndroidNotificationAction(
          kActionMarkTaken, 'Tomé ✓',
          showsUserInterface: false,
          cancelNotification: true,
        ),
        AndroidNotificationAction(
          kActionSkip, 'No puedo tomarlo',
          showsUserInterface: true,
          cancelNotification: true,
        ),
      ];
    }
    return const [
      AndroidNotificationAction(
        kActionMarkTaken, 'Tomé ✓',
        showsUserInterface: false,
        cancelNotification: true,
      ),
      AndroidNotificationAction(
        kActionSnooze, 'Posponer 30 min',
        showsUserInterface: false,
        cancelNotification: false,
      ),
    ];
  }
}
