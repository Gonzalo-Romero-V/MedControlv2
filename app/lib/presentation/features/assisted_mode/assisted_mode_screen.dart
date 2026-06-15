import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../providers/reminder_providers.dart';

/// Pantalla simplificada para modo asistido.
/// Solo muestra medicamentos del día con dos acciones: Tomé / No pude.
/// Sin navegación, sin configuración — el cuidador sale con el botón back del sistema.
class AssistedModeScreen extends ConsumerWidget {
  const AssistedModeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final remindersAsync = ref.watch(todayRemindersProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Mis medicamentos de hoy',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              DateFormat('EEEE d \'de\' MMMM', 'es').format(DateTime.now()),
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.normal),
            ),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        toolbarHeight: 70,
      ),
      body: remindersAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => _ErrorCard(message: e.toString()),
        data: (reminders) {
          final pending = reminders
              .where((r) =>
                  r.reminder.status == 'pending' ||
                  r.reminder.status == 'triggered' ||
                  r.reminder.status == 'snoozed')
              .toList();
          final done = reminders
              .where((r) =>
                  r.reminder.status == 'taken' ||
                  r.reminder.status == 'closed')
              .toList();

          if (reminders.isEmpty) return const _EmptyState();

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (pending.isNotEmpty) ...[
                _GroupHeader(
                    'Pendientes (${pending.length})', Colors.blue.shade700),
                const SizedBox(height: 8),
                ...pending.map((vm) => _AssistedReminderCard(
                      vm: vm,
                      onTaken: () async {
                        await ref
                            .read(recordIntakeUseCaseProvider)
                            .execute(reminder: vm.reminder, taken: true);
                        ref.invalidate(todayRemindersProvider);
                      },
                      onSkipped: () async {
                        await ref
                            .read(recordIntakeUseCaseProvider)
                            .execute(reminder: vm.reminder, taken: false);
                        ref.invalidate(todayRemindersProvider);
                      },
                    )),
                const SizedBox(height: 16),
              ],
              if (done.isNotEmpty) ...[
                _GroupHeader('Completados (${done.length})', Colors.grey),
                const SizedBox(height: 8),
                ...done.map((vm) => _DoneCard(vm: vm)),
              ],
            ],
          );
        },
      ),
    );
  }
}

// ─── Cards ────────────────────────────────────────────────────────────────────

class _AssistedReminderCard extends StatelessWidget {
  final ReminderViewModel vm;
  final VoidCallback onTaken;
  final VoidCallback onSkipped;

  const _AssistedReminderCard({
    required this.vm,
    required this.onTaken,
    required this.onSkipped,
  });

  @override
  Widget build(BuildContext context) {
    final time = DateFormat('HH:mm').format(vm.reminder.scheduledTime);
    final isCritical = vm.isCritical;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: isCritical
            ? const BorderSide(color: Colors.red, width: 2)
            : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isCritical)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.warning_amber, size: 16, color: Colors.red.shade700),
                    const SizedBox(width: 4),
                    Text(
                      'Medicamento crítico',
                      style: TextStyle(
                          color: Colors.red.shade700,
                          fontSize: 12,
                          fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            if (isCritical) const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: isCritical
                        ? Colors.red.shade50
                        : Theme.of(context).colorScheme.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      time,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: isCritical
                            ? Colors.red.shade700
                            : Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        vm.medicationName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      if (vm.reminder.ruleExplanation.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          vm.reminder.ruleExplanation,
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    icon: const Icon(Icons.check_circle_outline),
                    label: const Text('Tomé'),
                    onPressed: onTaken,
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.green,
                      minimumSize: const Size.fromHeight(52),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.cancel_outlined, color: Colors.red),
                    label: const Text(
                      'No pude',
                      style: TextStyle(color: Colors.red),
                    ),
                    onPressed: onSkipped,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.red),
                      minimumSize: const Size.fromHeight(52),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DoneCard extends StatelessWidget {
  final ReminderViewModel vm;
  const _DoneCard({required this.vm});

  @override
  Widget build(BuildContext context) {
    final time = DateFormat('HH:mm').format(vm.reminder.scheduledTime);
    final isTaken = vm.reminder.status == 'taken';

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: Colors.grey.shade50,
      child: ListTile(
        leading: Icon(
          isTaken ? Icons.check_circle : Icons.cancel,
          color: isTaken ? Colors.green : Colors.grey,
          size: 32,
        ),
        title: Text(
          vm.medicationName,
          style: TextStyle(
            color: Colors.grey.shade600,
            decoration: TextDecoration.lineThrough,
          ),
        ),
        trailing: Text(
          time,
          style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
        ),
      ),
    );
  }
}

class _GroupHeader extends StatelessWidget {
  final String title;
  final Color color;
  const _GroupHeader(this.title, this.color);

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        fontWeight: FontWeight.w700,
        color: color,
        fontSize: 13,
        letterSpacing: 0.5,
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_circle_outline,
              size: 80, color: Colors.green.shade200),
          const SizedBox(height: 16),
          Text(
            'No hay medicamentos para hoy',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.grey.shade500,
                ),
          ),
        ],
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  final String message;
  const _ErrorCard({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(message,
          style: TextStyle(color: Theme.of(context).colorScheme.error)),
    );
  }
}
