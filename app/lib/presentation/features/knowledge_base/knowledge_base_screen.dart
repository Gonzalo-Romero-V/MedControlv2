import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/historial_providers.dart';

// ─── Datos estáticos de reglas ────────────────────────────────────────────────

class _KbRule {
  final String id;
  final String name;
  final String condition;
  final String conclusion;
  final String layer;

  const _KbRule({
    required this.id,
    required this.name,
    required this.condition,
    required this.conclusion,
    required this.layer,
  });
}

const _rules = [
  _KbRule(
    id: 'R01',
    name: 'Intervalo fijo (cada N horas)',
    condition: 'frecuencia = "cada_N_horas"',
    conclusion: '24/N tomas diarias distribuidas desde las 08:00',
    layer: 'Horario',
  ),
  _KbRule(
    id: 'R02',
    name: 'N veces al día',
    condition: 'frecuencia = "N_veces_dia"',
    conclusion: 'N tomas distribuidas uniformemente en franja de vigilia (07:00–22:00)',
    layer: 'Horario',
  ),
  _KbRule(
    id: 'R03',
    name: 'Con comida',
    condition: 'instrucción contiene "con comida" / "after meals" / "con alimentos"',
    conclusion: 'Anclar tomas a desayuno, almuerzo y cena del perfil del paciente',
    layer: 'Horario',
  ),
  _KbRule(
    id: 'R04',
    name: 'Antes de dormir',
    condition: 'instrucción contiene "antes de dormir" / "before sleep"',
    conclusion: 'Hora = sleepTime del perfil del paciente',
    layer: 'Horario',
  ),
  _KbRule(
    id: 'R05',
    name: 'En ayunas',
    condition: 'instrucción contiene "en ayunas" / "before breakfast"',
    conclusion: 'Hora = breakfastTime del perfil − 30 minutos',
    layer: 'Horario',
  ),
  _KbRule(
    id: 'R06',
    name: 'A demanda',
    condition: 'frecuencia = "on_demand"',
    conclusion: 'Sin recordatorios programados — el paciente toma cuando lo necesita',
    layer: 'Horario',
  ),
  _KbRule(
    id: 'R07',
    name: 'Campos críticos faltantes',
    condition: 'dosis o frecuencia ausentes en los hechos de entrada',
    conclusion: 'No inferir — solicitar confirmación al humano antes de continuar',
    layer: 'Validación',
  ),
  _KbRule(
    id: 'R08',
    name: 'Política de posposición estándar',
    condition: 'medicamento.isCritical = false',
    conclusion: 'Ventana = intervalo/2, máximo 3 posposiciones de 30 minutos',
    layer: 'Snooze',
  ),
  _KbRule(
    id: 'R09',
    name: 'Política de posposición crítica',
    condition: 'medicamento.isCritical = true',
    conclusion: 'Ventana terapéutica estrecha: 30 min máx., sin posposición permitida',
    layer: 'Snooze',
  ),
  _KbRule(
    id: 'R10',
    name: 'Conflicto de principio activo',
    condition: 'existe tratamiento activo/suspendido con el mismo principio activo',
    conclusion: 'Generar ConflictAlert — requiere confirmación explícita del humano',
    layer: 'Seguridad',
  ),
  _KbRule(
    id: 'R11',
    name: 'Completar por duración',
    condition: 'treatment.type = "by_duration" && hoy ≥ startDate + durationDays',
    conclusion: 'Marcar tratamiento como "completed" automáticamente',
    layer: 'Lifecycle',
  ),
  _KbRule(
    id: 'R12',
    name: 'Completar por cantidad',
    condition: 'treatment.type = "by_quantity" && tomas_confirmadas ≥ totalDoses',
    conclusion: 'Marcar tratamiento como "completed" automáticamente',
    layer: 'Lifecycle',
  ),
  _KbRule(
    id: 'R13',
    name: 'Tratamiento indefinido',
    condition: 'treatment.type = "indefinite"',
    conclusion: 'No autocompletar — requiere cierre manual por el humano',
    layer: 'Lifecycle',
  ),
];

const _layerColors = {
  'Horario': Colors.blue,
  'Validación': Colors.amber,
  'Snooze': Colors.orange,
  'Seguridad': Colors.red,
  'Lifecycle': Colors.purple,
};

// ─── Widget principal ─────────────────────────────────────────────────────────

/// Body content for the "BC" (Base de Conocimiento) tab.
class KnowledgeBaseContent extends ConsumerWidget {
  const KnowledgeBaseContent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final factsAsync = ref.watch(activeFactsProvider);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _SystemCard(),
        const SizedBox(height: 16),
        _SectionHeader('Catálogo de reglas (R01–R13)'),
        const SizedBox(height: 8),
        ..._rules.map((r) => _RuleExpansionTile(rule: r)),
        const SizedBox(height: 16),
        _SectionHeader('Hechos activos'),
        const SizedBox(height: 8),
        factsAsync.when(
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: CircularProgressIndicator(),
            ),
          ),
          error: (e, _) => Text('Error: $e'),
          data: (facts) {
            if (facts.isEmpty) {
              return const _EmptyFacts();
            }
            return Column(
              children: facts.map((f) => _FactCard(fact: f)).toList(),
            );
          },
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

// ─── Sistema ──────────────────────────────────────────────────────────────────

class _SystemCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.5),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.psychology,
                    color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Sistema de producción',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Motor de inferencia hacia adelante (forward chaining) con 13 reglas de producción. '
              'Entrada: TreatmentFacts + PatientProfile. '
              'Salida: horarios sugeridos (SuggestedTime[]), trazas de inferencia (InferenceTrace[]) y alertas de conflicto (ConflictAlert[]).',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 8),
            const _LayerLegend(),
          ],
        ),
      ),
    );
  }
}

class _LayerLegend extends StatelessWidget {
  const _LayerLegend();

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 6,
      runSpacing: 4,
      children: _layerColors.entries.map((e) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: e.value.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            e.key,
            style: TextStyle(
              fontSize: 11,
              color: e.value,
              fontWeight: FontWeight.w600,
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ─── Reglas ───────────────────────────────────────────────────────────────────

class _RuleExpansionTile extends StatelessWidget {
  final _KbRule rule;

  const _RuleExpansionTile({required this.rule});

  @override
  Widget build(BuildContext context) {
    final layerColor = _layerColors[rule.layer] ?? Colors.grey;

    return Card(
      margin: const EdgeInsets.only(bottom: 6),
      child: ExpansionTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: layerColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              rule.id,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: layerColor,
              ),
            ),
          ),
        ),
        title: Text(
          rule.name,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
        subtitle: Container(
          margin: const EdgeInsets.only(top: 2),
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
          decoration: BoxDecoration(
            color: layerColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            rule.layer,
            style: TextStyle(
              fontSize: 10,
              color: layerColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        children: [
          _RuleDetail(label: 'Condición', text: rule.condition),
          const SizedBox(height: 6),
          _RuleDetail(label: 'Conclusión', text: rule.conclusion),
        ],
      ),
    );
  }
}

class _RuleDetail extends StatelessWidget {
  final String label;
  final String text;

  const _RuleDetail({required this.label, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Colors.grey.shade500,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
      ],
    );
  }
}

// ─── Hechos activos ───────────────────────────────────────────────────────────

class _FactCard extends StatelessWidget {
  final ActiveTreatmentFact fact;

  const _FactCard({required this.fact});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.medication, size: 16, color: Colors.blue),
                const SizedBox(width: 6),
                Text(
                  fact.medicationName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (fact.appliedRuleIds.isEmpty)
              Text(
                'Sin trazas de inferencia registradas',
                style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
              )
            else ...[
              Text(
                'Reglas aplicadas:',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Colors.grey.shade500,
                    ),
              ),
              const SizedBox(height: 4),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: fact.appliedRuleIds.map((ruleId) {
                  final rule = _rules.where((r) => r.id == ruleId).firstOrNull;
                  final color =
                      _layerColors[rule?.layer ?? ''] ?? Colors.blue;
                  return Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: color.withValues(alpha: 0.3)),
                    ),
                    child: Text(
                      rule != null ? '$ruleId · ${rule.name}' : ruleId,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: color,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _EmptyFacts extends StatelessWidget {
  const _EmptyFacts();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: Text(
          'Sin tratamientos activos — los hechos aparecerán aquí al registrar una receta.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey.shade400, fontSize: 13),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
    );
  }
}
