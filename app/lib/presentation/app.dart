import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'features/assisted_mode/assisted_mode_screen.dart';
import 'features/today_reminders/today_reminders_screen.dart';
import 'providers/patient_providers.dart';

class MedControlApp extends ConsumerWidget {
  const MedControlApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(appThemeProvider);
    final isAssisted = ref.watch(isAssistedModeProvider);

    return MaterialApp(
      title: 'MedControl',
      debugShowCheckedModeBanner: false,
      theme: theme,
      home: isAssisted
          ? const AssistedModeScreen()
          : const TodayRemindersScreen(),
    );
  }
}
