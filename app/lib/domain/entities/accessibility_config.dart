import 'dart:convert';

enum FontSizePreference { normal, large, veryLarge }

class AccessibilityConfig {
  final FontSizePreference fontSize;
  final bool highContrast;
  final bool largeTargets;
  final bool reduceAnimations;

  const AccessibilityConfig({
    this.fontSize = FontSizePreference.normal,
    this.highContrast = false,
    this.largeTargets = false,
    this.reduceAnimations = false,
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
      });

  static FontSizePreference _parseFontSize(String? value) => switch (value) {
        'large' => FontSizePreference.large,
        'veryLarge' => FontSizePreference.veryLarge,
        _ => FontSizePreference.normal,
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
  }) =>
      AccessibilityConfig(
        fontSize: fontSize ?? this.fontSize,
        highContrast: highContrast ?? this.highContrast,
        largeTargets: largeTargets ?? this.largeTargets,
        reduceAnimations: reduceAnimations ?? this.reduceAnimations,
      );
}
