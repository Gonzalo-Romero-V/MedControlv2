import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/entities/med_time.dart';
import '../../../infrastructure/notifications/notification_service.dart';
import '../../providers/patient_providers.dart';

class ProfileSettingsScreen extends ConsumerStatefulWidget {
  const ProfileSettingsScreen({super.key});

  @override
  ConsumerState<ProfileSettingsScreen> createState() =>
      _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState
    extends ConsumerState<ProfileSettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameCtrl;

  // Profile type
  String _profileType = 'autonomous';

  // Meal/sleep times
  late TimeOfDay _breakfastTime;
  late TimeOfDay _lunchTime;
  late TimeOfDay _dinnerTime;
  late TimeOfDay _sleepTime;

  // Accessibility
  late AccessibilityConfig _accessibility;

  bool _saving = false;
  bool _initialized = false;
  bool _requestingFsiPermission = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController();
    // Defaults prevent LateInitializationError on first frame before stream emits
    _breakfastTime = const TimeOfDay(hour: 7, minute: 0);
    _lunchTime = const TimeOfDay(hour: 13, minute: 0);
    _dinnerTime = const TimeOfDay(hour: 19, minute: 0);
    _sleepTime = const TimeOfDay(hour: 21, minute: 0);
    _accessibility = const AccessibilityConfig();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  void _initFromPatient() {
    if (_initialized) return;
    final patient = ref.read(activePatientProvider).valueOrNull;
    if (patient == null) return;
    _initialized = true;
    _nameCtrl.text = patient.name;
    _profileType = patient.profileType;
    _breakfastTime = _minutesToTimeOfDay(patient.breakfastTime);
    _lunchTime = _minutesToTimeOfDay(patient.lunchTime);
    _dinnerTime = _minutesToTimeOfDay(patient.dinnerTime);
    _sleepTime = _minutesToTimeOfDay(patient.sleepTime);
    _accessibility = AccessibilityConfig.fromJson(patient.accessibilityConfig);
  }

  TimeOfDay _minutesToTimeOfDay(int minutes) =>
      TimeOfDay(hour: minutes ~/ 60, minute: minutes % 60);

  MedTime _timeOfDayToMedTime(TimeOfDay t) => MedTime(t.hour, t.minute);

  String _formatTime(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  Future<void> _pickTime(TimeOfDay current, ValueChanged<TimeOfDay> onPicked,
      String label) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: current,
      helpText: label,
    );
    if (picked != null) onPicked(picked);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final patient = ref.read(activePatientProvider).valueOrNull;
    if (patient == null) return;

    setState(() => _saving = true);
    try {
      await ref.read(updatePatientUseCaseProvider).execute(
            patientId: patient.id,
            name: _nameCtrl.text.trim(),
            profileType: _profileType,
            breakfastTime: _timeOfDayToMedTime(_breakfastTime),
            lunchTime: _timeOfDayToMedTime(_lunchTime),
            dinnerTime: _timeOfDayToMedTime(_dinnerTime),
            sleepTime: _timeOfDayToMedTime(_sleepTime),
            accessibilityConfig: _accessibility,
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Perfil guardado')),
        );
        Navigator.pop(context);
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _requestFullScreenPermission() async {
    setState(() => _requestingFsiPermission = true);
    try {
      final granted = await NotificationService.instance
          .requestFullScreenIntentPermission();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(granted
            ? 'Permiso concedido. Las alarmas aparecerán sobre otras apps ✓'
            : 'Permiso no concedido. Las alarmas solo aparecerán al bloquear la pantalla.'),
        duration: const Duration(seconds: 4),
      ));
    } finally {
      if (mounted) setState(() => _requestingFsiPermission = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Initialize on first build once data is available
    ref.listen(activePatientProvider, (_, next) {
      if (!_initialized) setState(_initFromPatient);
    });
    _initFromPatient();

    final patientAsync = ref.watch(activePatientProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuración de perfil'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: patientAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (_) => Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _SectionHeader('Datos del paciente'),
              const SizedBox(height: 12),
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Nombre',
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Ingresá un nombre' : null,
              ),
              const SizedBox(height: 24),
              _SectionHeader('Tipo de perfil'),
              const SizedBox(height: 8),
              _ProfileTypeSelector(
                value: _profileType,
                onChanged: (v) => setState(() => _profileType = v),
              ),
              const SizedBox(height: 24),
              _SectionHeader('Horarios de comida y sueño'),
              Text(
                'El motor de inferencia usa estos horarios para calcular cuándo tomar los medicamentos.',
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: Colors.grey.shade600),
              ),
              const SizedBox(height: 12),
              _TimeRow(
                label: 'Desayuno',
                icon: Icons.free_breakfast,
                time: _breakfastTime,
                format: _formatTime,
                onTap: () => _pickTime(_breakfastTime,
                    (t) => setState(() => _breakfastTime = t), 'Hora de desayuno'),
              ),
              _TimeRow(
                label: 'Almuerzo',
                icon: Icons.lunch_dining,
                time: _lunchTime,
                format: _formatTime,
                onTap: () => _pickTime(_lunchTime,
                    (t) => setState(() => _lunchTime = t), 'Hora de almuerzo'),
              ),
              _TimeRow(
                label: 'Cena',
                icon: Icons.dinner_dining,
                time: _dinnerTime,
                format: _formatTime,
                onTap: () => _pickTime(_dinnerTime,
                    (t) => setState(() => _dinnerTime = t), 'Hora de cena'),
              ),
              _TimeRow(
                label: 'Dormir',
                icon: Icons.bedtime,
                time: _sleepTime,
                format: _formatTime,
                onTap: () => _pickTime(_sleepTime,
                    (t) => setState(() => _sleepTime = t), 'Hora de dormir'),
              ),
              const SizedBox(height: 24),
              _SectionHeader('Accesibilidad'),
              const SizedBox(height: 12),
              _FontSizeSelector(
                value: _accessibility.fontSize,
                onChanged: (v) =>
                    setState(() => _accessibility = _accessibility.copyWith(fontSize: v)),
              ),
              const SizedBox(height: 8),
              SwitchListTile(
                title: const Text('Alto contraste'),
                subtitle: const Text('Texto negro sobre fondo blanco'),
                value: _accessibility.highContrast,
                onChanged: (v) => setState(
                    () => _accessibility = _accessibility.copyWith(highContrast: v)),
              ),
              SwitchListTile(
                title: const Text('Objetivos táctiles grandes'),
                subtitle: const Text('Aumenta el área de toque de los botones'),
                value: _accessibility.largeTargets,
                onChanged: (v) => setState(
                    () => _accessibility = _accessibility.copyWith(largeTargets: v)),
              ),
              SwitchListTile(
                title: const Text('Reducir animaciones'),
                subtitle: const Text('Menos movimiento en la pantalla'),
                value: _accessibility.reduceAnimations,
                onChanged: (v) => setState(() =>
                    _accessibility = _accessibility.copyWith(reduceAnimations: v)),
              ),
              const SizedBox(height: 24),
              _SectionHeader('Alertas de medicamentos'),
              const SizedBox(height: 8),
              Text(
                'Elegí cómo te avisa la app cuando es hora de tomar el medicamento.',
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: Colors.grey.shade600),
              ),
              const SizedBox(height: 12),
              _NotificationModeSelector(
                value: _accessibility.notificationMode,
                onChanged: (v) => setState(
                    () => _accessibility = _accessibility.copyWith(notificationMode: v)),
              ),
              AnimatedSize(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                child: _accessibility.notificationMode == NotificationMode.active
                    ? Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: _FullScreenPermissionBanner(
                          requesting: _requestingFsiPermission,
                          onRequest: _requestFullScreenPermission,
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
              const SizedBox(height: 32),
              FilledButton(
                onPressed: _saving ? null : _save,
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                ),
                child: _saving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('Guardar cambios'),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Sub-widgets ──────────────────────────────────────────────────────────────

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

class _ProfileTypeSelector extends StatelessWidget {
  final String value;
  final ValueChanged<String> onChanged;

  const _ProfileTypeSelector({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return RadioGroup<String>(
      groupValue: value,
      onChanged: (v) => onChanged(v!),
      child: Column(
        children: const [
          RadioListTile<String>(
            title: Text('Autónomo'),
            subtitle: Text('Acceso completo a todas las funciones'),
            value: 'autonomous',
          ),
          RadioListTile<String>(
            title: Text('Asistido'),
            subtitle: Text(
                'Solo muestra qué tomar ahora — el cuidador configura desde el modo autónomo'),
            value: 'assisted',
          ),
        ],
      ),
    );
  }
}

class _TimeRow extends StatelessWidget {
  final String label;
  final IconData icon;
  final TimeOfDay time;
  final String Function(TimeOfDay) format;
  final VoidCallback onTap;

  const _TimeRow({
    required this.label,
    required this.icon,
    required this.time,
    required this.format,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
      title: Text(label),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            format(time),
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
          ),
          const SizedBox(width: 8),
          Icon(Icons.edit, size: 16, color: Colors.grey.shade400),
        ],
      ),
      onTap: onTap,
    );
  }
}

class _FontSizeSelector extends StatelessWidget {
  final FontSizePreference value;
  final ValueChanged<FontSizePreference> onChanged;

  const _FontSizeSelector({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tamaño de fuente',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 8),
        SegmentedButton<FontSizePreference>(
          segments: const [
            ButtonSegment(
              value: FontSizePreference.normal,
              label: Text('Normal'),
            ),
            ButtonSegment(
              value: FontSizePreference.large,
              label: Text('Grande'),
            ),
            ButtonSegment(
              value: FontSizePreference.veryLarge,
              label: Text('Muy grande'),
            ),
          ],
          selected: {value},
          onSelectionChanged: (s) => onChanged(s.first),
          style: const ButtonStyle(
            tapTargetSize: MaterialTapTargetSize.padded,
          ),
        ),
      ],
    );
  }
}

class _NotificationModeSelector extends StatelessWidget {
  final NotificationMode value;
  final ValueChanged<NotificationMode> onChanged;

  const _NotificationModeSelector({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _ModeCard(
          mode: NotificationMode.active,
          selected: value == NotificationMode.active,
          icon: Icons.notifications_active,
          title: 'Alerta activa',
          description: 'Sonido + vibración fuerte. Aparece aunque el teléfono esté bloqueado. '
              'Recomendado para no olvidar ninguna toma.',
          onTap: () => onChanged(NotificationMode.active),
        ),
        const SizedBox(height: 8),
        _ModeCard(
          mode: NotificationMode.subtle,
          selected: value == NotificationMode.subtle,
          icon: Icons.vibration,
          title: 'Discreta',
          description: 'Solo vibración, sin sonido. Para entornos tranquilos o quienes prefieren menos ruido.',
          onTap: () => onChanged(NotificationMode.subtle),
        ),
      ],
    );
  }
}

class _ModeCard extends StatelessWidget {
  final NotificationMode mode;
  final bool selected;
  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;

  const _ModeCard({
    required this.mode,
    required this.selected,
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = selected
        ? Theme.of(context).colorScheme.primary
        : Colors.grey.shade400;
    final bg = selected
        ? Theme.of(context).colorScheme.primaryContainer
        : Colors.grey.shade50;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? Theme.of(context).colorScheme.primary : Colors.grey.shade300,
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: selected
                          ? Theme.of(context).colorScheme.onPrimaryContainer
                          : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: selected
                              ? Theme.of(context).colorScheme.onPrimaryContainer
                              : Colors.grey.shade600,
                        ),
                  ),
                ],
              ),
            ),
            if (selected) Icon(Icons.check_circle, color: color),
          ],
        ),
      ),
    );
  }
}

// ─── Banner de permiso pantalla completa ─────────────────────────────────────

class _FullScreenPermissionBanner extends StatelessWidget {
  const _FullScreenPermissionBanner({
    required this.requesting,
    required this.onRequest,
  });

  final bool requesting;
  final VoidCallback onRequest;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: cs.secondaryContainer.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.secondary.withValues(alpha: 0.4)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, color: cs.secondary, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Alarma sobre otras apps (Android 14+)',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: cs.onSecondaryContainer,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Para que la alarma aparezca aunque estés usando otra app, '
                  'concedé el permiso "Notificaciones de pantalla completa" en Ajustes.',
                  style: TextStyle(fontSize: 12, color: cs.onSecondaryContainer),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 34,
                  child: FilledButton.tonal(
                    onPressed: requesting ? null : onRequest,
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      textStyle: const TextStyle(fontSize: 12),
                    ),
                    child: requesting
                        ? const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Verificar / Conceder permiso'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
