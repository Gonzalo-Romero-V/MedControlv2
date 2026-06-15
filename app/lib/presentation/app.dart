import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'features/assisted_mode/assisted_mode_screen.dart';
import 'features/historial/historial_screen.dart';
import 'features/knowledge_base/knowledge_base_screen.dart';
import 'features/today_reminders/today_reminders_screen.dart';
import 'providers/patient_providers.dart';
import 'providers/reminder_providers.dart';
import 'screens/prescription/prescription_flow_screen.dart';
import 'screens/settings/profile_settings_screen.dart';

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
      home: isAssisted ? const AssistedModeScreen() : const _MainShell(),
    );
  }
}

// ─── Shell con NavigationBar ──────────────────────────────────────────────────

class _MainShell extends ConsumerStatefulWidget {
  const _MainShell();

  @override
  ConsumerState<_MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<_MainShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _buildTitle(_index),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          if (_index == 0) ...[
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: 'Actualizar',
              onPressed: () => ref.invalidate(todayRemindersProvider),
            ),
            IconButton(
              icon: const Icon(Icons.person_outline),
              tooltip: 'Perfil',
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                    builder: (_) => const ProfileSettingsScreen()),
              ),
            ),
          ],
        ],
      ),
      body: IndexedStack(
        index: _index,
        children: const [
          TodayRemindersContent(),
          HistorialContent(),
          KnowledgeBaseContent(),
        ],
      ),
      floatingActionButton: _index == 0
          ? FloatingActionButton.extended(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                    builder: (_) => const PrescriptionFlowScreen()),
              ),
              icon: const Icon(Icons.add),
              label: const Text('Registrar receta'),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.today_outlined),
            selectedIcon: Icon(Icons.today),
            label: 'Hoy',
          ),
          NavigationDestination(
            icon: Icon(Icons.history_outlined),
            selectedIcon: Icon(Icons.history),
            label: 'Historial',
          ),
          NavigationDestination(
            icon: Icon(Icons.psychology_outlined),
            selectedIcon: Icon(Icons.psychology),
            label: 'BC',
          ),
        ],
      ),
    );
  }

  Widget _buildTitle(int index) {
    switch (index) {
      case 0:
        return Text('Hoy — ${DateFormat('d MMM', 'es').format(DateTime.now())}');
      case 1:
        return const Text('Historial');
      case 2:
        return const Text('Base de Conocimiento');
      default:
        return const Text('MedControl');
    }
  }
}
