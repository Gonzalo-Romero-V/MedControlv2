import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'features/today_reminders/today_reminders_screen.dart';

class MedControlApp extends ConsumerWidget {
  const MedControlApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'MedControl',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1976D2)),
        useMaterial3: true,
        textTheme: const TextTheme().apply(
          fontSizeFactor: 1.1,
        ),
      ),
      home: const TodayRemindersScreen(),
    );
  }
}
