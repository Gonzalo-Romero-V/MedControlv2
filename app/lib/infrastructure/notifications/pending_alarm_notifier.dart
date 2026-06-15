import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Singleton that holds a pending alarm notification response until the widget
/// tree is ready to navigate to [AlarmScreen]. Set before or after runApp().
final pendingAlarmNotifier = ValueNotifier<NotificationResponse?>(null);
