import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../providers/historial_providers.dart';
import 'treatment_detail_screen.dart';

/// Body content for the "Historial" tab.
class HistorialContent extends ConsumerWidget {
  const HistorialContent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(treatmentHistoryProvider);

    if (historyAsync.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (historyAsync.hasError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline,
                  size: 48, color: Theme.of(context).colorScheme.error),
              const SizedBox(height: 12),
              const Text(
                'No se pudo cargar el historial.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                icon: const Icon(Icons.refresh),
                label: const Text('Reintentar'),
                onPressed: () => ref.invalidate(treatmentHistoryProvider),
              ),
            ],
          ),
        ),
      );
    }

    final history = historyAsync.value ?? [];

    return RefreshIndicator(
      onRefresh: () {
        ref.invalidate(treatmentHistoryProvider);
        return ref.read(treatmentHistoryProvider.future);
      },
      child: history.isEmpty
          ? LayoutBuilder(
              builder: (context, constraints) => ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(
                    height: constraints.maxHeight,
                    child: const _EmptyHistorial(),
                  ),
                ],
              ),
            )
          : ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              itemCount: history.length,
              itemBuilder: (context, i) => _TreatmentCard(
                vm: history[i],
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => TreatmentDetailScreen(vm: history[i]),
                  ),
                ),
              ),
            ),
    );
  }
}

class _TreatmentCard extends StatelessWidget {
  final TreatmentHistoryViewModel vm;
  final VoidCallback onTap;

  const _TreatmentCard({required this.vm, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final t = vm.treatment;
    final startStr = DateFormat('d MMM yyyy', 'es').format(t.startDate);
    final pct = vm.adherence;
    final adherenceColor = pct >= 0.8
        ? Colors.green
        : pct >= 0.5
            ? Colors.orange
            : Colors.red;

    final (statusLabel, statusColor) = switch (t.status) {
      'active' => ('Activo', Colors.blue),
      'completed' => ('Completado', Colors.green),
      'abandoned' => ('Abandonado', Colors.grey),
      'suspended' => ('Suspendido', Colors.orange),
      _ => (t.status, Colors.grey),
    };

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
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
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  _Chip(label: statusLabel, color: statusColor),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                _frequencyLabel(t),
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: Colors.grey.shade600),
              ),
              Text(
                'Desde $startStr',
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: Colors.grey.shade500),
              ),
              if (vm.hasReminders) ...[
                const SizedBox(height: 12),
                Semantics(
                  label: 'Adherencia al tratamiento',
                  value: '${(pct * 100).round()} por ciento',
                  child: Row(
                    children: [
                      Expanded(
                        child: LinearProgressIndicator(
                          value: pct,
                          backgroundColor:
                              adherenceColor.withValues(alpha: 0.15),
                          color: adherenceColor,
                          minHeight: 6,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        '${(pct * 100).round()}%',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          color: adherenceColor,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${vm.intakesTaken}/${vm.remindersTotal} dosis',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: Colors.grey.shade500),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _frequencyLabel(dynamic t) {
    switch (t.frequencyType as String) {
      case 'every_n_hours':
        return 'Cada ${t.frequencyValue} horas';
      case 'n_times_day':
        return '${t.frequencyValue} veces al día';
      case 'on_demand':
        return 'A demanda';
      default:
        return t.frequencyType as String;
    }
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final Color color;

  const _Chip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
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

class _EmptyHistorial extends StatelessWidget {
  const _EmptyHistorial();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.history, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              'Sin tratamientos registrados',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(color: Colors.grey.shade500),
            ),
            const SizedBox(height: 8),
            Text(
              'Los tratamientos aparecerán aquí una vez que registres una receta.',
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
