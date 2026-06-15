import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../domain/entities/inference_result.dart';
import '../../../domain/entities/med_time.dart';
import '../../../domain/entities/parsed_prescription.dart';
import '../../../domain/entities/treatment_facts.dart';
import '../../providers/prescription_flow_provider.dart';

/// Pantalla de revisión de horarios sugeridos por el motor de inferencia.
///
/// Muestra cada horario con la traza de la regla que lo generó (explicabilidad).
/// El usuario puede ajustar los horarios antes de confirmar.
/// INVARIANTE: el usuario confirma explícitamente antes de guardar.
class ScheduleReviewScreen extends ConsumerStatefulWidget {
  final ParsedPrescription prescription;
  final InferenceResult inferenceResult;

  const ScheduleReviewScreen({
    super.key,
    required this.prescription,
    required this.inferenceResult,
  });

  @override
  ConsumerState<ScheduleReviewScreen> createState() =>
      _ScheduleReviewScreenState();
}

class _ScheduleReviewScreenState extends ConsumerState<ScheduleReviewScreen> {
  late List<TimeOfDay> _confirmedTimes;
  DateTime _startDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _confirmedTimes = widget.inferenceResult.suggestions
        .map((s) => TimeOfDay(hour: s.time.hour, minute: s.time.minute))
        .toList();
  }

  /// Intervalo entre tomas según la frecuencia de la prescripción.
  /// Retorna null si el tipo de frecuencia no permite recalcular
  /// (a demanda, única dosis, o sin valor).
  Duration? get _interval {
    final p = widget.prescription;
    if (p.frequencyType == FrequencyType.everyNHours) {
      final h = p.frequencyValue;
      return h != null && h > 0 ? Duration(hours: h) : null;
    }
    if (p.frequencyType == FrequencyType.nTimesDay) {
      final n = p.frequencyValue;
      if (n == null || n <= 1) return null;
      return Duration(minutes: (24 * 60 / n).round());
    }
    return null;
  }

  /// Recalcula todos los horarios a partir de [first] usando el intervalo.
  void _recalculateFromFirst(TimeOfDay first) {
    final interval = _interval;
    if (interval == null) return;
    setState(() {
      for (var i = 0; i < _confirmedTimes.length; i++) {
        final minutesFromMidnight =
            first.hour * 60 + first.minute + i * interval.inMinutes;
        _confirmedTimes[i] = TimeOfDay(
          hour: (minutesFromMidnight ~/ 60) % 24,
          minute: minutesFromMidnight % 60,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final result = widget.inferenceResult;
    final isSaving = ref.watch(prescriptionFlowProvider) is PrescriptionFlowSaving;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Revisar horarios sugeridos'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        leading: BackButton(
          onPressed: isSaving
              ? null
              : () => ref
                  .read(prescriptionFlowProvider.notifier)
                  .backToReviewPrescription(),
        ),
      ),
      body: Column(
        children: [
          _ScheduleBanner(prescription: widget.prescription),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (result.hasConflicts) ...[
                    _ConflictAlertCard(conflicts: result.conflicts),
                    const SizedBox(height: 16),
                  ],
                  if (result.isOnDemand) ...[
                    _OnDemandCard(traces: result.traces),
                  ] else if (result.hasMissingFields) ...[
                    _MissingFieldsCard(
                      fields: result.missingFields,
                      traces: result.traces,
                    ),
                  ] else ...[
                    _StartDatePicker(
                      date: _startDate,
                      onChanged: (d) => setState(() => _startDate = d),
                    ),
                    if (_interval != null && _confirmedTimes.length > 1) ...[
                      const SizedBox(height: 12),
                      _FirstDosePicker(
                        firstTime: _confirmedTimes.first,
                        interval: _interval!,
                        onChanged: _recalculateFromFirst,
                      ),
                    ],
                    const SizedBox(height: 16),
                    _SuggestionsSection(
                      suggestions: result.suggestions,
                      confirmedTimes: _confirmedTimes,
                      onTimeChanged: (i, t) =>
                          setState(() => _confirmedTimes[i] = t),
                    ),
                    if (result.snoozePolicy != null) ...[
                      const SizedBox(height: 16),
                      _SnoozePolicyCard(policy: result.snoozePolicy!),
                    ],
                  ],
                  const SizedBox(height: 16),
                  _InferenceTracesExpansion(traces: result.traces),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _ConfirmBar(
        isOnDemand: result.isOnDemand,
        isSaving: isSaving,
        onConfirm: () => ref
            .read(prescriptionFlowProvider.notifier)
            .confirmAndSave(
              startDate: _startDate,
              confirmedTimes: _confirmedTimes,
            ),
      ),
    );
  }
}

// ─── Widgets ──────────────────────────────────────────────────────────────────

class _ScheduleBanner extends StatelessWidget {
  final ParsedPrescription prescription;
  const _ScheduleBanner({required this.prescription});

  @override
  Widget build(BuildContext context) {
    final name = prescription.medicationName ?? 'Medicamento';
    return Container(
      width: double.infinity,
      color: Theme.of(context).colorScheme.primaryContainer,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(Icons.medication,
              color: Theme.of(context).colorScheme.onPrimaryContainer),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              '$name — revisa los horarios sugeridos y ajustalos si es necesario.',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onPrimaryContainer,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ConflictAlertCard extends StatelessWidget {
  final List<ConflictAlert> conflicts;
  const _ConflictAlertCard({required this.conflicts});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.shade300, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.orange.shade700),
              const SizedBox(width: 8),
              Text(
                'Alerta de conflicto (Regla R10)',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.orange.shade800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...conflicts.map(
            (c) => Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                c.explanation,
                style: TextStyle(color: Colors.orange.shade900),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OnDemandCard extends StatelessWidget {
  final List<InferenceTrace> traces;
  const _OnDemandCard({required this.traces});

  @override
  Widget build(BuildContext context) {
    final trace = traces.firstWhere(
      (t) => t.ruleId == 'R06',
      orElse: () => traces.first,
    );
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: Colors.blue.shade700),
              const SizedBox(width: 8),
              Text(
                'Medicamento a demanda',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(trace.explanation,
              style: TextStyle(color: Colors.blue.shade900)),
          const SizedBox(height: 8),
          Text(
            'Se guardará el tratamiento sin recordatorios automáticos. '
            'Podrás registrar cada toma manualmente.',
            style: TextStyle(
              color: Colors.blue.shade700,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

class _MissingFieldsCard extends StatelessWidget {
  final List<String> fields;
  final List<InferenceTrace> traces;
  const _MissingFieldsCard({required this.fields, required this.traces});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.error_outline,
                  color: Theme.of(context).colorScheme.onErrorContainer),
              const SizedBox(width: 8),
              Text(
                'Faltan datos para calcular horarios',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onErrorContainer,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...fields.map(
            (f) => Text('• $f',
                style: TextStyle(
                    color: Theme.of(context).colorScheme.onErrorContainer)),
          ),
          const SizedBox(height: 8),
          TextButton.icon(
            icon: const Icon(Icons.arrow_back),
            label: const Text('Volver a editar la receta'),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}

class _StartDatePicker extends StatelessWidget {
  final DateTime date;
  final ValueChanged<DateTime> onChanged;

  const _StartDatePicker({required this.date, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: date,
          firstDate: DateTime.now().subtract(const Duration(days: 7)),
          lastDate: DateTime.now().add(const Duration(days: 30)),
          helpText: 'Fecha de inicio del tratamiento',
        );
        if (picked != null) onChanged(picked);
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today, size: 20),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Fecha de inicio',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                ),
                Text(
                  DateFormat('dd/MM/yyyy').format(date),
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ],
            ),
            const Spacer(),
            Icon(Icons.edit, size: 16, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }
}

class _SuggestionsSection extends StatelessWidget {
  final List<SuggestedTime> suggestions;
  final List<TimeOfDay> confirmedTimes;
  final void Function(int index, TimeOfDay time) onTimeChanged;

  const _SuggestionsSection({
    required this.suggestions,
    required this.confirmedTimes,
    required this.onTimeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Horarios sugeridos',
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 4),
        Text(
          'Tocá un horario para ajustarlo. Cada sugerencia muestra la regla aplicada.',
          style: Theme.of(context)
              .textTheme
              .bodySmall
              ?.copyWith(color: Colors.grey.shade600),
        ),
        const SizedBox(height: 12),
        ...List.generate(suggestions.length, (i) {
          final suggestion = suggestions[i];
          final time = confirmedTimes[i];
          return _SuggestionTile(
            index: i,
            suggestion: suggestion,
            confirmedTime: time,
            onTap: () async {
              final picked = await showTimePicker(
                context: context,
                initialTime: time,
                helpText: 'Ajustar horario ${i + 1}',
              );
              if (picked != null) onTimeChanged(i, picked);
            },
          );
        }),
      ],
    );
  }
}

class _SuggestionTile extends StatelessWidget {
  final int index;
  final SuggestedTime suggestion;
  final TimeOfDay confirmedTime;
  final VoidCallback onTap;

  const _SuggestionTile({
    required this.index,
    required this.suggestion,
    required this.confirmedTime,
    required this.onTap,
  });

  bool get _wasModified =>
      confirmedTime.hour != suggestion.time.hour ||
      confirmedTime.minute != suggestion.time.minute;

  String _formatTime(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade100,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    _formatTime(confirmedTime),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Toma ${index + 1}',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        if (_wasModified) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.green.shade100,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'Ajustado',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.green.shade700,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      suggestion.explanation,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey.shade600,
                          ),
                    ),
                    if (_wasModified) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Sugerido: ${MedTime(suggestion.time.hour, suggestion.time.minute).format()}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey.shade400,
                              decoration: TextDecoration.lineThrough,
                            ),
                      ),
                    ],
                  ],
                ),
              ),
              Icon(Icons.edit, size: 16, color: Colors.grey.shade400),
            ],
          ),
        ),
      ),
    );
  }
}

class _SnoozePolicyCard extends StatelessWidget {
  final SnoozePolicy policy;
  const _SnoozePolicyCard({required this.policy});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: policy.isCritical ? Colors.red.shade50 : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: policy.isCritical ? Colors.red.shade200 : Colors.grey.shade200,
        ),
      ),
      child: Row(
        children: [
          Icon(
            policy.isCritical ? Icons.timer : Icons.snooze,
            color: policy.isCritical ? Colors.red : Colors.grey,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              policy.explanation,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}

class _InferenceTracesExpansion extends StatefulWidget {
  final List<InferenceTrace> traces;
  const _InferenceTracesExpansion({required this.traces});

  @override
  State<_InferenceTracesExpansion> createState() =>
      _InferenceTracesExpansionState();
}

class _InferenceTracesExpansionState
    extends State<_InferenceTracesExpansion> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () => setState(() => _expanded = !_expanded),
          child: Row(
            children: [
              Icon(
                _expanded ? Icons.expand_less : Icons.expand_more,
                color: Colors.grey,
              ),
              const SizedBox(width: 4),
              Text(
                'Reglas aplicadas (${widget.traces.length})',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey.shade600,
                    ),
              ),
            ],
          ),
        ),
        if (_expanded) ...[
          const SizedBox(height: 8),
          ...widget.traces.map(
            (t) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade100,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            t.ruleId,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade700,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            t.conclusion,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      t.explanation,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey.shade600,
                          ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

/// Picker de primera toma con recálculo automático.
/// Muestra la hora de la primera toma y, al cambiarla,
/// redistribuye todas las tomas según el intervalo de la prescripción.
class _FirstDosePicker extends StatelessWidget {
  final TimeOfDay firstTime;
  final Duration interval;
  final ValueChanged<TimeOfDay> onChanged;

  const _FirstDosePicker({
    required this.firstTime,
    required this.interval,
    required this.onChanged,
  });

  String _formatTime(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  String _intervalLabel() {
    final h = interval.inMinutes ~/ 60;
    final m = interval.inMinutes % 60;
    if (m == 0) return 'cada $h hs';
    return 'cada ${h}h ${m}min';
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        final picked = await showTimePicker(
          context: context,
          initialTime: firstTime,
          helpText: 'Hora de la primera toma — las siguientes se recalculan automáticamente',
        );
        if (picked != null) onChanged(picked);
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.secondaryContainer,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: Theme.of(context).colorScheme.secondary.withOpacity(0.4)),
        ),
        child: Row(
          children: [
            Icon(Icons.schedule,
                color: Theme.of(context).colorScheme.onSecondaryContainer),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ajustar primera toma',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSecondaryContainer,
                      fontSize: 13,
                    ),
                  ),
                  Text(
                    'Las siguientes se calculan ${_intervalLabel()} a partir de esta hora.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSecondaryContainer
                              .withOpacity(0.7),
                        ),
                  ),
                ],
              ),
            ),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _formatTime(firstTime),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: Theme.of(context).colorScheme.onSecondary,
                ),
              ),
            ),
            const SizedBox(width: 6),
            Icon(Icons.edit, size: 16,
                color: Theme.of(context).colorScheme.onSecondaryContainer),
          ],
        ),
      ),
    );
  }
}

class _ConfirmBar extends StatelessWidget {
  final bool isOnDemand;
  final bool isSaving;
  final VoidCallback onConfirm;

  const _ConfirmBar({
    required this.isOnDemand,
    required this.isSaving,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: FilledButton.icon(
          onPressed: isSaving ? null : onConfirm,
          icon: isSaving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : const Icon(Icons.check_circle_outline),
          label: Text(
            isOnDemand
                ? 'Guardar medicamento a demanda'
                : 'Confirmar y guardar tratamiento',
          ),
          style: FilledButton.styleFrom(
            minimumSize: const Size.fromHeight(52),
          ),
        ),
      ),
    );
  }
}
