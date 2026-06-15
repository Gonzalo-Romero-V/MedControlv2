import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/entities/parsed_prescription.dart';
import '../../../domain/entities/treatment_facts.dart';
import '../../providers/prescription_flow_provider.dart';

/// Pantalla de revisión de datos extraídos por la IA.
///
/// INVARIANTE DE DOMINIO: el usuario SIEMPRE revisa y confirma los datos antes
/// de continuar. Ningún campo se acepta ciegamente.
///
/// Campos con datos de la IA tienen badge "IA". Campos vacíos (críticos) se
/// marcan en rojo. El botón "Calcular horarios" se activa solo cuando todos
/// los campos críticos están completos.
class PrescriptionReviewScreen extends ConsumerStatefulWidget {
  final ParsedPrescription prescription;
  final bool isAiParsed;
  final bool usedCloudVision;

  const PrescriptionReviewScreen({
    super.key,
    required this.prescription,
    required this.isAiParsed,
    this.usedCloudVision = false,
  });

  @override
  ConsumerState<PrescriptionReviewScreen> createState() =>
      _PrescriptionReviewScreenState();
}

class _PrescriptionReviewScreenState
    extends ConsumerState<PrescriptionReviewScreen> {
  // Campos de texto
  late TextEditingController _medicationNameCtrl;
  late TextEditingController _activeIngredientCtrl;
  late TextEditingController _doseAmountCtrl;
  late TextEditingController _doseUnitCtrl;
  late TextEditingController _frequencyValueCtrl;
  late TextEditingController _routeCtrl;
  late TextEditingController _specialInstructionsCtrl;
  late TextEditingController _durationDaysCtrl;
  late TextEditingController _totalDosesCtrl;

  // Valores de dropdown
  FrequencyType? _frequencyType;
  String? _endCriterionType;
  bool _isCritical = false;

  late bool _showOcrText;

  @override
  void initState() {
    super.initState();
    // Auto-expand OCR text in OcrOnly mode so the user can see what was captured
    _showOcrText = !widget.isAiParsed && widget.prescription.rawOcrText.isNotEmpty;
    final p = widget.prescription;
    _medicationNameCtrl = TextEditingController(text: p.medicationName ?? '');
    _activeIngredientCtrl =
        TextEditingController(text: p.activeIngredient ?? '');
    _doseAmountCtrl =
        TextEditingController(text: p.doseAmount?.toString() ?? '');
    _doseUnitCtrl = TextEditingController(text: p.doseUnit ?? '');
    _frequencyValueCtrl =
        TextEditingController(text: p.frequencyValue?.toString() ?? '');
    _routeCtrl = TextEditingController(text: p.route ?? '');
    _specialInstructionsCtrl =
        TextEditingController(text: p.specialInstructions ?? '');
    _durationDaysCtrl =
        TextEditingController(text: p.durationDays?.toString() ?? '');
    _totalDosesCtrl =
        TextEditingController(text: p.totalDoses?.toString() ?? '');

    _frequencyType = p.frequencyType;
    _endCriterionType = p.endCriterionType;
    _isCritical = p.isCritical;
  }

  @override
  void dispose() {
    _medicationNameCtrl.dispose();
    _activeIngredientCtrl.dispose();
    _doseAmountCtrl.dispose();
    _doseUnitCtrl.dispose();
    _frequencyValueCtrl.dispose();
    _routeCtrl.dispose();
    _specialInstructionsCtrl.dispose();
    _durationDaysCtrl.dispose();
    _totalDosesCtrl.dispose();
    super.dispose();
  }

  ParsedPrescription _buildCorrected() {
    final frequencyValue = int.tryParse(_frequencyValueCtrl.text.trim());
    final durationDays = int.tryParse(_durationDaysCtrl.text.trim());
    final totalDoses = int.tryParse(_totalDosesCtrl.text.trim());
    final doseAmount = double.tryParse(_doseAmountCtrl.text.trim());

    return widget.prescription.copyWith(
      medicationName: _medicationNameCtrl.text.trim().isEmpty
          ? null
          : _medicationNameCtrl.text.trim(),
      activeIngredient: _activeIngredientCtrl.text.trim().isEmpty
          ? null
          : _activeIngredientCtrl.text.trim(),
      doseAmount: doseAmount,
      clearDoseAmount: doseAmount == null,
      doseUnit: _doseUnitCtrl.text.trim().isEmpty
          ? null
          : _doseUnitCtrl.text.trim(),
      frequencyType: _frequencyType,
      frequencyValue: frequencyValue,
      clearFrequencyValue: frequencyValue == null,
      route: _routeCtrl.text.trim().isEmpty ? null : _routeCtrl.text.trim(),
      specialInstructions: _specialInstructionsCtrl.text.trim().isEmpty
          ? null
          : _specialInstructionsCtrl.text.trim(),
      endCriterionType: _endCriterionType,
      durationDays: durationDays,
      clearDurationDays: durationDays == null,
      totalDoses: totalDoses,
      clearTotalDoses: totalDoses == null,
      isCritical: _isCritical,
    );
  }

  bool get _canProceed => _buildCorrected().hasCriticalFields;

  bool _fieldHasAiValue(dynamic originalValue) =>
      widget.isAiParsed && originalValue != null;

  @override
  Widget build(BuildContext context) {
    final bool needsFrequencyValue = _frequencyType == FrequencyType.everyNHours ||
        _frequencyType == FrequencyType.nTimesDay;
    final bool showDurationDays = _endCriterionType == 'por_duracion';
    final bool showTotalDoses = _endCriterionType == 'por_cantidad';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Revisar datos de la receta'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        leading: BackButton(
          onPressed: () =>
              ref.read(prescriptionFlowProvider.notifier).reset(),
        ),
      ),
      body: Column(
        children: [
          _ReviewBanner(
            isAiParsed: widget.isAiParsed,
            usedCloudVision: widget.usedCloudVision,
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SectionHeader('Medicamento'),
                  _ReviewField(
                    label: 'Nombre del medicamento',
                    controller: _medicationNameCtrl,
                    hasAiValue: _fieldHasAiValue(widget.prescription.medicationName),
                    isRequired: true,
                    onChanged: (_) => setState(() {}),
                  ),
                  _ReviewField(
                    label: 'Principio activo',
                    controller: _activeIngredientCtrl,
                    hasAiValue: _fieldHasAiValue(widget.prescription.activeIngredient),
                    isRequired: false,
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 8),
                  _SectionHeader('Dosis'),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 2,
                        child: _ReviewField(
                          label: 'Cantidad',
                          controller: _doseAmountCtrl,
                          hasAiValue: _fieldHasAiValue(widget.prescription.doseAmount),
                          isRequired: true,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          onChanged: (_) => setState(() {}),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 3,
                        child: _ReviewField(
                          label: 'Unidad (ej: tabletas, mg, ml)',
                          controller: _doseUnitCtrl,
                          hasAiValue: _fieldHasAiValue(widget.prescription.doseUnit),
                          isRequired: true,
                          onChanged: (_) => setState(() {}),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _SectionHeader('Frecuencia'),
                  _FrequencyTypeDropdown(
                    value: _frequencyType,
                    hasAiValue: _fieldHasAiValue(widget.prescription.frequencyType),
                    onChanged: (v) => setState(() => _frequencyType = v),
                  ),
                  if (needsFrequencyValue) ...[
                    const SizedBox(height: 8),
                    _ReviewField(
                      label: _frequencyType == FrequencyType.everyNHours
                          ? 'Cada cuántas horas'
                          : 'Cuántas veces al día',
                      controller: _frequencyValueCtrl,
                      hasAiValue: _fieldHasAiValue(widget.prescription.frequencyValue),
                      isRequired: true,
                      keyboardType: TextInputType.number,
                      onChanged: (_) => setState(() {}),
                    ),
                  ],
                  const SizedBox(height: 8),
                  _SectionHeader('Administración'),
                  _ReviewField(
                    label: 'Vía (ej: oral, tópica, inhalatoria)',
                    controller: _routeCtrl,
                    hasAiValue: _fieldHasAiValue(widget.prescription.route),
                    isRequired: false,
                    onChanged: (_) => setState(() {}),
                  ),
                  _ReviewField(
                    label: 'Instrucciones especiales (ej: con comida)',
                    controller: _specialInstructionsCtrl,
                    hasAiValue: _fieldHasAiValue(widget.prescription.specialInstructions),
                    isRequired: false,
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 8),
                  _SectionHeader('Duración del tratamiento'),
                  _EndCriterionDropdown(
                    value: _endCriterionType,
                    hasAiValue: _fieldHasAiValue(widget.prescription.endCriterionType),
                    onChanged: (v) => setState(() {
                      _endCriterionType = v;
                      if (v != 'por_duracion') _durationDaysCtrl.clear();
                      if (v != 'por_cantidad') _totalDosesCtrl.clear();
                    }),
                  ),
                  if (showDurationDays) ...[
                    const SizedBox(height: 8),
                    _ReviewField(
                      label: 'Duración en días',
                      controller: _durationDaysCtrl,
                      hasAiValue: _fieldHasAiValue(widget.prescription.durationDays),
                      isRequired: false,
                      keyboardType: TextInputType.number,
                      onChanged: (_) => setState(() {}),
                    ),
                  ],
                  if (showTotalDoses) ...[
                    const SizedBox(height: 8),
                    _ReviewField(
                      label: 'Cantidad total de dosis',
                      controller: _totalDosesCtrl,
                      hasAiValue: _fieldHasAiValue(widget.prescription.totalDoses),
                      isRequired: false,
                      keyboardType: TextInputType.number,
                      onChanged: (_) => setState(() {}),
                    ),
                  ],
                  const SizedBox(height: 8),
                  _SectionHeader('Alerta especial'),
                  _CriticalSwitch(
                    value: _isCritical,
                    hasAiValue: _fieldHasAiValue(widget.prescription.isCritical
                        ? true
                        : null),
                    onChanged: (v) => setState(() => _isCritical = v),
                  ),
                  if (widget.prescription.rawOcrText.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    _OcrTextExpansion(
                      ocrText: widget.prescription.rawOcrText,
                      isExpanded: _showOcrText,
                      onToggle: () =>
                          setState(() => _showOcrText = !_showOcrText),
                    ),
                  ],
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _BottomBar(
        canProceed: _canProceed,
        onProceed: () {
          final corrected = _buildCorrected();
          ref
              .read(prescriptionFlowProvider.notifier)
              .submitReviewedPrescription(corrected);
        },
      ),
    );
  }
}

// ─── Widgets auxiliares ───────────────────────────────────────────────────────

class _ReviewBanner extends StatelessWidget {
  final bool isAiParsed;
  final bool usedCloudVision;
  const _ReviewBanner({required this.isAiParsed, required this.usedCloudVision});

  String get _ocrLabel => usedCloudVision ? 'Cloud Vision' : 'ML Kit (offline)';

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Theme.of(context).colorScheme.primaryContainer,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(Icons.rate_review_outlined,
              color: Theme.of(context).colorScheme.onPrimaryContainer,
              size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              isAiParsed
                  ? 'OCR: $_ocrLabel • IA completó el formulario. Revisá y corregí cualquier campo antes de continuar.'
                  : 'OCR: $_ocrLabel • El texto capturado se muestra abajo. Completá los campos manualmente.',
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

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 6),
      child: Text(
        title,
        style: Theme.of(context)
            .textTheme
            .labelLarge
            ?.copyWith(color: Theme.of(context).colorScheme.primary),
      ),
    );
  }
}

class _ReviewField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool hasAiValue;
  final bool isRequired;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;

  const _ReviewField({
    required this.label,
    required this.controller,
    required this.hasAiValue,
    required this.isRequired,
    this.keyboardType,
    this.onChanged,
  });

  bool get _isEmpty => controller.text.trim().isEmpty;
  bool get _showRequiredError => isRequired && _isEmpty;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: _showRequiredError
                          ? Theme.of(context).colorScheme.error
                          : Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
              ),
              if (isRequired)
                Text(' *',
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                        fontSize: 12)),
              if (hasAiValue && !_isEmpty) ...[
                const SizedBox(width: 6),
                _AiBadge(),
              ],
            ],
          ),
          const SizedBox(height: 4),
          TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            onChanged: onChanged,
            decoration: InputDecoration(
              isDense: true,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: _showRequiredError
                      ? Theme.of(context).colorScheme.error
                      : Colors.grey.shade300,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: _showRequiredError
                      ? Theme.of(context).colorScheme.error
                      : Theme.of(context).colorScheme.primary,
                  width: 2,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: _showRequiredError
                      ? Theme.of(context).colorScheme.error
                      : Colors.grey.shade300,
                ),
              ),
              errorText: _showRequiredError ? 'Campo requerido' : null,
            ),
          ),
        ],
      ),
    );
  }
}

class _AiBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.amber.shade100,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.amber.shade300),
      ),
      child: Text(
        'IA',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: Colors.amber.shade800,
        ),
      ),
    );
  }
}

class _FrequencyTypeDropdown extends StatelessWidget {
  final FrequencyType? value;
  final bool hasAiValue;
  final ValueChanged<FrequencyType?> onChanged;

  const _FrequencyTypeDropdown({
    required this.value,
    required this.hasAiValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final items = [
      DropdownMenuItem(
        value: FrequencyType.everyNHours,
        child: const Text('Cada N horas'),
      ),
      DropdownMenuItem(
        value: FrequencyType.nTimesDay,
        child: const Text('N veces al día'),
      ),
      DropdownMenuItem(
        value: FrequencyType.onDemand,
        child: const Text('A demanda (según necesidad)'),
      ),
      DropdownMenuItem(
        value: FrequencyType.tapering,
        child: const Text('Pauta de reducción'),
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Tipo de frecuencia *',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: value == null
                        ? Theme.of(context).colorScheme.error
                        : Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
            ),
            if (hasAiValue && value != null) ...[
              const SizedBox(width: 6),
              _AiBadge(),
            ],
          ],
        ),
        const SizedBox(height: 4),
        DropdownButtonFormField<FrequencyType>(
          initialValue: value,
          items: items,
          onChanged: onChanged,
          decoration: InputDecoration(
            isDense: true,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: value == null
                    ? Theme.of(context).colorScheme.error
                    : Colors.grey.shade300,
              ),
            ),
            errorText: value == null ? 'Campo requerido' : null,
          ),
          hint: const Text('Seleccionar…'),
        ),
      ],
    );
  }
}

class _EndCriterionDropdown extends StatelessWidget {
  final String? value;
  final bool hasAiValue;
  final ValueChanged<String?> onChanged;

  const _EndCriterionDropdown({
    required this.value,
    required this.hasAiValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final items = [
      const DropdownMenuItem(value: 'por_duracion', child: Text('Por duración (días)')),
      const DropdownMenuItem(value: 'por_cantidad', child: Text('Por cantidad de dosis')),
      const DropdownMenuItem(value: 'indefinido', child: Text('Indefinido / crónico')),
      const DropdownMenuItem(value: 'a_demanda', child: Text('Solo a demanda')),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Criterio de fin',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
            ),
            if (hasAiValue && value != null) ...[
              const SizedBox(width: 6),
              _AiBadge(),
            ],
          ],
        ),
        const SizedBox(height: 4),
        DropdownButtonFormField<String>(
          initialValue: value,
          items: items,
          onChanged: onChanged,
          decoration: InputDecoration(
            isDense: true,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          hint: const Text('Seleccionar…'),
        ),
      ],
    );
  }
}

class _CriticalSwitch extends StatelessWidget {
  final bool value;
  final bool hasAiValue;
  final ValueChanged<bool> onChanged;

  const _CriticalSwitch({
    required this.value,
    required this.hasAiValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: value ? Colors.red.shade50 : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: value ? Colors.red.shade200 : Colors.grey.shade200,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.warning_amber_rounded,
            color: value ? Colors.red : Colors.grey,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      'Medicamento crítico',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    if (hasAiValue) ...[
                      const SizedBox(width: 6),
                      _AiBadge(),
                    ],
                  ],
                ),
                Text(
                  'Insulina, anticoagulantes, anticonvulsivos — ventana de posposición estricta',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                ),
              ],
            ),
          ),
          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}

class _OcrTextExpansion extends StatelessWidget {
  final String ocrText;
  final bool isExpanded;
  final VoidCallback onToggle;

  const _OcrTextExpansion({
    required this.ocrText,
    required this.isExpanded,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: onToggle,
          child: Row(
            children: [
              Icon(
                isExpanded ? Icons.expand_less : Icons.expand_more,
                color: Colors.grey,
              ),
              const SizedBox(width: 4),
              Text(
                'Texto original (OCR)',
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
        if (isExpanded) ...[
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: SelectableText(
              ocrText,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(fontFamily: 'monospace'),
            ),
          ),
        ],
      ],
    );
  }
}

class _BottomBar extends StatelessWidget {
  final bool canProceed;
  final VoidCallback onProceed;

  const _BottomBar({required this.canProceed, required this.onProceed});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!canProceed)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  'Completá los campos obligatorios (*) para continuar',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                    fontSize: 12,
                  ),
                ),
              ),
            FilledButton.icon(
              onPressed: canProceed ? onProceed : null,
              icon: const Icon(Icons.schedule),
              label: const Text('Calcular horarios sugeridos'),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
