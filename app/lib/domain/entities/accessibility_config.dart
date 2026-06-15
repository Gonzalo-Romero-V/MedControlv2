import 'dart:convert';

enum FontSizePreference { normal, large, veryLarge }

/// Modo de alerta para recordatorios de medicamentos.
/// - [subtle]  Vibración solamente — para entornos tranquilos.
/// - [active]  Sonido + vibración fuerte + aparece sobre pantalla bloqueada.
///             Recomendado para adultos mayores o quienes puedan olvidar tomas.
enum NotificationMode { subtle, active }

class AccessibilityConfig {
  final FontSizePreference fontSize;
  final bool highContrast;
  final bool largeTargets;
  final bool reduceAnimations;
  /// Modo de alerta para notificaciones de medicamentos. Default: alerta activa.
  final NotificationMode notificationMode;

  const AccessibilityConfig({
    this.fontSize = FontSizePreference.normal,
    this.highContrast = false,
    this.largeTargets = false,
    this.reduceAnimations = false,
    this.notificationMode = NotificationMode.active,
  });

  static const defaults = AccessibilityConfig();

  factory AccessibilityConfig.fromJson(String jsonStr) {
    if (jsonStr.isEmpty || jsonStr == '{}') return const AccessibilityConfig();
    try {
      final map = jsonDecode(jsonStr) as Map<String, dynamic>;
      return AccessibilityConfig(
        fontSize: _parseFontSize(map['font_size'] as String?),
        highContrast: (map['high_contrast'] as bool?) ?? false,
        largeTargets: (map['large_targets'] as bool?) ?? false,
        reduceAnimations: (map['reduce_animations'] as bool?) ?? false,
        notificationMode: _parseNotificationMode(map['notification_mode'] as String?),
      );
    } catch (_) {
      return const AccessibilityConfig();
    }
  }

  String toJson() => jsonEncode({
        'font_size': fontSize.name,
        'high_contrast': highContrast,
        'large_targets': largeTargets,
        'reduce_animations': reduceAnimations,
        'notification_mode': notificationMode.name,
      });

  static FontSizePreference _parseFontSize(String? value) => switch (value) {
        'large' => FontSizePreference.large,
        'veryLarge' => FontSizePreference.veryLarge,
        _ => FontSizePreference.normal,
      };

  static NotificationMode _parseNotificationMode(String? value) => switch (value) {
        'subtle' => NotificationMode.subtle,
        _ => NotificationMode.active,
      };

  // 1.1 is the app baseline; large/veryLarge scale from there
  double get fontSizeFactor => switch (fontSize) {
        FontSizePreference.normal => 1.1,
        FontSizePreference.large => 1.3,
        FontSizePreference.veryLarge => 1.5,
      };

  AccessibilityConfig copyWith({
    FontSizePreference? fontSize,
    bool? highContrast,
    bool? largeTargets,
    bool? reduceAnimations,
    NotificationMode? notificationMode,
  }) =>
      AccessibilityConfig(
        fontSize: fontSize ?? this.fontSize,
        highContrast: highContrast ?? this.highContrast,
        largeTargets: largeTargets ?? this.largeTargets,
        reduceAnimations: reduceAnimations ?? this.reduceAnimations,
        notificationMode: notificationMode ?? this.notificationMode,
      );
}
