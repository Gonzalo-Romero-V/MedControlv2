import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'features/today_reminders/today_reminders_screen.dart';
import 'screens/prescription/prescription_flow_screen.dart';

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
      home: const _HomeScreen(),
    );
  }
}

class _HomeScreen extends StatelessWidget {
  const _HomeScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const TodayRemindersScreen(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => const PrescriptionFlowScreen(),
          ),
        ),
        icon: const Icon(Icons.add),
        label: const Text('Registrar receta'),
      ),
    );
  }
}
