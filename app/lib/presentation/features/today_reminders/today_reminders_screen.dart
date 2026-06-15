import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../providers/reminder_providers.dart';

/// Body content for the "Hoy" tab.
/// The parent _MainShell provides the Scaffold, AppBar, FAB, and NavigationBar.
class TodayRemindersContent extends ConsumerWidget {
  const TodayRemindersContent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final remindersAsync = ref.watch(todayRemindersProvider);

    return remindersAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => _ErrorState(message: e.toString()),
      data: (reminders) {
        if (reminders.isEmpty) return const _EmptyState();
        return ListView.separated(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: reminders.length,
          separatorBuilder: (_, i) => const Divider(height: 1, indent: 16),
          itemBuilder: (context, i) {
            final vm = reminders[i];
            return _ReminderTile(
              vm: vm,
              onAction: () => _showActionSheet(context, ref, vm),
            );
          },
        );
      },
    );
  }

  Future<void> _showActionSheet(
    BuildContext context,
    WidgetRef ref,
    ReminderViewModel vm,
  ) async {
    final isDone = vm.reminder.status == 'taken' || vm.reminder.status == 'closed';
    if (isDone) return;

    await showModalBottomSheet<void>(
      context: context,
      builder: (_) => _ReminderActionSheet(vm: vm, ref: ref),
    );

    ref.invalidate(todayRemindersProvider);
  }
}

// ─── Tiles ────────────────────────────────────────────────────────────────────

class _ReminderTile extends StatelessWidget {
  final ReminderViewModel vm;
  final VoidCallback onAction;

  const _ReminderTile({required this.vm, required this.onAction});

  @override
  Widget build(BuildContext context) {
    final reminder = vm.reminder;
    final scheduledTime = reminder.scheduledTime;
    final timeStr = DateFormat('HH:mm').format(scheduledTime);
    final isDone =
        reminder.status == 'taken' || reminder.status == 'closed';

    return ListTile(
      onTap: isDone ? null : onAction,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: _TimeCircle(
        timeStr: timeStr,
        status: reminder.status,
        isCritical: vm.isCritical,
      ),
      title: Text(
        vm.medicationName,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          decoration: isDone ? TextDecoration.lineThrough : null,
          color: isDone ? Colors.grey : null,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (reminder.ruleExplanation.isNotEmpty)
            Text(
              reminder.ruleExplanation,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: Colors.grey.shade600),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          const SizedBox(height: 2),
          _StatusBadge(status: reminder.status, snoozeCount: reminder.snoozeCount),
        ],
      ),
      trailing: isDone
          ? null
          : Icon(Icons.chevron_right, color: Colors.grey.shade400),
    );
  }
}

class _TimeCircle extends StatelessWidget {
  final String timeStr;
  final String status;
  final bool isCritical;

  const _TimeCircle({
    required this.timeStr,
    required this.status,
    required this.isCritical,
  });

  Color get _color {
    switch (status) {
      case 'taken':
        return Colors.green;
      case 'closed':
        return Colors.grey;
      case 'snoozed':
        return Colors.orange;
      case 'expired':
        return Colors.red.shade300;
      default:
        return isCritical ? Colors.red : Colors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.12),
        shape: BoxShape.circle,
        border: Border.all(color: _color.withValues(alpha: 0.4)),
      ),
      child: Center(
        child: Text(
          timeStr,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 13,
            color: _color,
          ),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  final int snoozeCount;

  const _StatusBadge({required this.status, required this.snoozeCount});

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      'pending' => ('Pendiente', Colors.blue),
      'triggered' => ('Disparado', Colors.amber.shade700),
      'snoozed' => ('Pospuesto ($snoozeCount)', Colors.orange),
      'taken' => ('Tomado', Colors.green),
      'expired' => ('Vencido', Colors.red),
      'closed' => ('Cerrado', Colors.grey),
      _ => (status, Colors.grey),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

// ─── Action sheet ─────────────────────────────────────────────────────────────

class _ReminderActionSheet extends ConsumerStatefulWidget {
  final ReminderViewModel vm;
  final WidgetRef ref;

  const _ReminderActionSheet({required this.vm, required this.ref});

  @override
  ConsumerState<_ReminderActionSheet> createState() =>
      _ReminderActionSheetState();
}

class _ReminderActionSheetState extends ConsumerState<_ReminderActionSheet> {
  bool _loading = false;

  Future<void> _recordIntake(bool taken) async {
    setState(() => _loading = true);
    try {
      await ref.read(recordIntakeUseCaseProvider).execute(
            reminder: widget.vm.reminder,
            taken: taken,
          );
      if (mounted) Navigator.pop(context);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _snooze() async {
    setState(() => _loading = true);
    try {
      final allowed = await ref.read(snoozeReminderUseCaseProvider).execute(
            reminder: widget.vm.reminder,
            isCritical: widget.vm.isCritical,
            medicationName: widget.vm.medicationName,
          );
      if (mounted) {
        Navigator.pop(context);
        if (!allowed) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                widget.vm.isCritical
                    ? 'Este medicamento es crítico — no se puede posponer.'
                    : 'Límite de postposiciones alcanzado.',
              ),
            ),
          );
        }
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final reminder = widget.vm.reminder;
    final timeStr = DateFormat('HH:mm').format(reminder.scheduledTime);
    final snoozesLeft =
        widget.vm.isCritical ? 0 : (3 - reminder.snoozeCount);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              widget.vm.medicationName,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            Text(
              'Programado: $timeStr',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: Colors.grey.shade600),
            ),
            if (reminder.ruleExplanation.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                reminder.ruleExplanation,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: Colors.grey.shade500),
              ),
            ],
            const SizedBox(height: 20),
            if (_loading)
              const Center(child: CircularProgressIndicator())
            else ...[
              FilledButton.icon(
                icon: const Icon(Icons.check_circle_outline),
                label: const Text('Tomé el medicamento'),
                onPressed: () => _recordIntake(true),
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.green,
                  minimumSize: const Size.fromHeight(48),
                ),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                icon: const Icon(Icons.snooze),
                label: Text(
                  snoozesLeft > 0
                      ? 'Posponer 30 min ($snoozesLeft restantes)'
                      : 'Posponer (no disponible)',
                ),
                onPressed: snoozesLeft > 0 ? _snooze : null,
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                ),
              ),
              const SizedBox(height: 8),
              TextButton.icon(
                icon: const Icon(Icons.cancel_outlined, color: Colors.red),
                label: const Text(
                  'No puedo tomarlo ahora',
                  style: TextStyle(color: Colors.red),
                ),
                onPressed: () => _recordIntake(false),
                style: TextButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ─── Empty / Error ────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.medication_outlined,
                size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              'Sin recordatorios para hoy',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(color: Colors.grey.shade500),
            ),
            const SizedBox(height: 8),
            Text(
              'Registrá una receta con el botón + para comenzar.',
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: Colors.grey.shade400),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  const _ErrorState({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline,
                size: 48, color: Theme.of(context).colorScheme.error),
            const SizedBox(height: 12),
            Text(
              'Error al cargar los recordatorios',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
            const SizedBox(height: 4),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
