import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../infrastructure/database/app_database.dart';
import '../../providers/historial_providers.dart';

class TreatmentDetailScreen extends ConsumerWidget {
  final TreatmentHistoryViewModel vm;

  const TreatmentDetailScreen({super.key, required this.vm});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final remindersAsync = ref.watch(remindersByTreatmentProvider(vm.treatment.id));
    final intakesAsync = ref.watch(intakesByTreatmentProvider(vm.treatment.id));

    return Scaffold(
      appBar: AppBar(
        title: Text(vm.medicationName),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: remindersAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (reminders) => intakesAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Error: $e')),
          data: (intakes) {
            final intakeMap = {
              for (final intake in intakes) intake.reminderId: intake,
            };
            return _DetailBody(
              vm: vm,
              reminders: reminders,
              intakeMap: intakeMap,
            );
          },
        ),
      ),
    );
  }
}

class _DetailBody extends StatelessWidget {
  final TreatmentHistoryViewModel vm;
  final List<RemindersTableData> reminders;
  final Map<String, IntakesTableData> intakeMap;

  const _DetailBody({
    required this.vm,
    required this.reminders,
    required this.intakeMap,
  });

  @override
  Widget build(BuildContext context) {
    final treatment = vm.treatment;
    final startStr = DateFormat('d MMM yyyy', 'es').format(treatment.startDate);
    final endStr = treatment.endedAt != null
        ? DateFormat('d MMM yyyy', 'es').format(treatment.endedAt!)
        : null;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _TreatmentInfoCard(
          vm: vm,
          startStr: startStr,
          endStr: endStr,
        ),
        const SizedBox(height: 16),
        if (vm.hasReminders) ...[
          _AdherenceCard(vm: vm),
          const SizedBox(height: 16),
        ],
        Text(
          'Recordatorios (${reminders.length})',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: 8),
        if (reminders.isEmpty)
          const _EmptyReminders()
        else
          ...reminders.map(
            (r) => _ReminderRow(reminder: r, intake: intakeMap[r.id]),
          ),
      ],
    );
  }
}

class _TreatmentInfoCard extends StatelessWidget {
  final TreatmentHistoryViewModel vm;
  final String startStr;
  final String? endStr;

  const _TreatmentInfoCard({
    required this.vm,
    required this.startStr,
    required this.endStr,
  });

  @override
  Widget build(BuildContext context) {
    final t = vm.treatment;
    final statusChip = _StatusChip(status: t.status);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    vm.medicationName,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                statusChip,
              ],
            ),
            const SizedBox(height: 8),
            _InfoRow(
              icon: Icons.medical_information_outlined,
              text: '${t.doseAmount} ${t.doseUnit} — ${t.route}',
            ),
            _InfoRow(
              icon: Icons.schedule,
              text: _frequencyLabel(t),
            ),
            _InfoRow(
              icon: Icons.calendar_today,
              text: endStr != null
                  ? 'Del $startStr al $endStr'
                  : 'Desde $startStr',
            ),
            if (t.specialInstructions?.isNotEmpty == true)
              _InfoRow(
                icon: Icons.info_outline,
                text: t.specialInstructions!,
              ),
          ],
        ),
      ),
    );
  }

  String _frequencyLabel(TreatmentsTableData t) {
    switch (t.frequencyType) {
      case 'every_n_hours':
        return 'Cada ${t.frequencyValue} horas';
      case 'n_times_day':
        return '${t.frequencyValue} veces al día';
      case 'on_demand':
        return 'A demanda';
      default:
        return t.frequencyType;
    }
  }
}

class _AdherenceCard extends StatelessWidget {
  final TreatmentHistoryViewModel vm;

  const _AdherenceCard({required this.vm});

  @override
  Widget build(BuildContext context) {
    final pct = vm.adherence;
    final color = pct >= 0.8
        ? Colors.green
        : pct >= 0.5
            ? Colors.orange
            : Colors.red;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Adherencia',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 12),
            Semantics(
              label: 'Adherencia al tratamiento',
              value: '${(pct * 100).round()} por ciento',
              child: Row(
                children: [
                  Expanded(
                    child: LinearProgressIndicator(
                      value: pct,
                      backgroundColor: color.withValues(alpha: 0.15),
                      color: color,
                      minHeight: 10,
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '${(pct * 100).round()}%',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: color,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${vm.intakesTaken} de ${vm.remindersTotal} dosis confirmadas',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReminderRow extends StatelessWidget {
  final RemindersTableData reminder;
  final IntakesTableData? intake;

  const _ReminderRow({required this.reminder, required this.intake});

  @override
  Widget build(BuildContext context) {
    final timeStr = DateFormat('d MMM HH:mm', 'es').format(reminder.scheduledTime);
    final result = intake?.result ?? reminder.status;

    final (icon, color, label) = switch (result) {
      'taken' => (Icons.check_circle, Colors.green, 'Tomado'),
      'taken_late' => (Icons.check_circle_outline, Colors.teal, 'Tomado tarde'),
      'skipped' => (Icons.cancel, Colors.red, 'Omitido'),
      'pending' => (Icons.radio_button_unchecked, Colors.blue, 'Pendiente'),
      'snoozed' => (Icons.snooze, Colors.orange, 'Pospuesto'),
      'expired' => (Icons.timer_off_outlined, Colors.red.shade300, 'Vencido'),
      _ => (Icons.radio_button_unchecked, Colors.grey, result),
    };

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(timeStr, style: const TextStyle(fontSize: 13)),
                if (reminder.ruleExplanation.isNotEmpty)
                  Text(
                    reminder.ruleExplanation,
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String status;
  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      'active' => ('Activo', Colors.blue),
      'completed' => ('Completado', Colors.green),
      'abandoned' => ('Abandonado', Colors.grey),
      'suspended' => ('Suspendido', Colors.orange),
      _ => (status, Colors.grey),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: Colors.grey.shade500),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyReminders extends StatelessWidget {
  const _EmptyReminders();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Center(
        child: Text(
          'Sin recordatorios registrados',
          style: TextStyle(color: Colors.grey.shade400),
        ),
      ),
    );
  }
}
