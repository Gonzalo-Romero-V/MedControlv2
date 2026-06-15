import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../infrastructure/notifications/notification_service.dart';
import '../infrastructure/notifications/pending_alarm_notifier.dart';
import 'features/alarm/alarm_screen.dart';
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
    final reduceAnimations = ref.watch(reduceAnimationsProvider);

    return MaterialApp(
      title: 'MedControl',
      debugShowCheckedModeBanner: false,
      theme: theme,
      themeAnimationDuration:
          reduceAnimations ? Duration.zero : const Duration(milliseconds: 200),
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
  void initState() {
    super.initState();
    pendingAlarmNotifier.addListener(_onPendingAlarm);
    // Handle a response that was set before this widget was built
    // (app-killed case: set in main() before runApp).
    WidgetsBinding.instance.addPostFrameCallback((_) => _onPendingAlarm());
  }

  @override
  void dispose() {
    pendingAlarmNotifier.removeListener(_onPendingAlarm);
    super.dispose();
  }

  void _onPendingAlarm() {
    final response = pendingAlarmNotifier.value;
    if (response == null || !mounted) return;
    pendingAlarmNotifier.value = null;
    _navigateToAlarm(response);
  }

  void _navigateToAlarm(NotificationResponse response) {
    final parsed = NotificationService.parsePayload(response.payload);
    if (parsed == null) return;
    Navigator.of(context).push(
      PageRouteBuilder(
        fullscreenDialog: true,
        pageBuilder: (context, anim, secondaryAnim) => AlarmScreen(
          reminderId: parsed.reminderId,
          medicationName: parsed.medicationName,
          isCritical: parsed.isCritical,
        ),
        transitionsBuilder: (context, animation, secondaryAnim, child) =>
            FadeTransition(opacity: animation, child: child),
        transitionDuration: const Duration(milliseconds: 200),
      ),
    );
  }

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
            label: 'Conocimiento',
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
