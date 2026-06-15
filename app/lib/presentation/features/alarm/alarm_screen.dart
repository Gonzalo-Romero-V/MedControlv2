import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../domain/use_cases/record_intake_use_case.dart';
import '../../../domain/use_cases/snooze_reminder_use_case.dart';
import '../../../infrastructure/database/app_database.dart';
import '../../../infrastructure/notifications/notification_service.dart';
import '../../providers/database_providers.dart';
import '../../providers/reminder_providers.dart';

/// Pantalla de alarma en modo ACTIVO. Se muestra a pantalla completa, incluso
/// sobre la pantalla de bloqueo, cuando llega la hora de tomar un medicamento.
/// Solo puede cerrarse tomando una acción (tomé / posponer / no puedo).
class AlarmScreen extends ConsumerStatefulWidget {
  const AlarmScreen({
    super.key,
    required this.reminderId,
    required this.medicationName,
    required this.isCritical,
  });

  final String reminderId;
  final String medicationName;
  final bool isCritical;

  @override
  ConsumerState<AlarmScreen> createState() => _AlarmScreenState();
}

class _AlarmScreenState extends ConsumerState<AlarmScreen> {
  RemindersTableData? _reminder;
  bool _loading = true;
  bool _processing = false;

  static const _bg = Color(0xFF0D1B2A);

  @override
  void initState() {
    super.initState();
    _loadReminder();
  }

  Future<void> _loadReminder() async {
    final reminder =
        await ref.read(reminderDaoProvider).getById(widget.reminderId);
    if (!mounted) return;
    setState(() {
      _reminder = reminder;
      _loading = false;
    });
    // If the reminder was already processed (e.g. double-fire), close silently.
    if (reminder == null || reminder.status != 'pending') {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) Navigator.of(context).pop();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: _bg,
        body: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }

    final reminder = _reminder;
    if (reminder == null) return const SizedBox.shrink();

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) => _confirmDismiss(),
      child: Scaffold(
        backgroundColor: _bg,
        body: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(child: _buildInfo(reminder)),
              _buildActions(reminder),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 8, 0),
      child: Row(
        children: [
          const Spacer(),
          TextButton(
            onPressed: _confirmDismiss,
            style: TextButton.styleFrom(
              foregroundColor: Colors.white30,
              textStyle: const TextStyle(fontSize: 13),
            ),
            child: const Text('Cerrar sin acción'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfo(RemindersTableData reminder) {
    final timeStr =
        DateFormat('HH:mm').format(reminder.scheduledTime);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          widget.isCritical ? Icons.medication : Icons.alarm,
          size: 72,
          color: widget.isCritical
              ? Colors.red.shade300
              : Colors.blue.shade200,
        ),
        const SizedBox(height: 12),
        Text(
          timeStr,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 52,
            fontWeight: FontWeight.w200,
            letterSpacing: 4,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Hora de tomar',
          style: TextStyle(color: Colors.white54, fontSize: 16),
        ),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Text(
            widget.medicationName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        if (widget.isCritical) ...[
          const SizedBox(height: 20),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 32),
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.red.shade900.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.red.shade700, width: 1),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.warning_amber_rounded,
                    color: Colors.red.shade300, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Medicamento crítico',
                  style:
                      TextStyle(color: Colors.red.shade200, fontSize: 14),
                ),
              ],
            ),
          ),
        ],
        if (reminder.ruleExplanation.isNotEmpty) ...[
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              reminder.ruleExplanation,
              style: const TextStyle(color: Colors.white30, fontSize: 13),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildActions(RemindersTableData reminder) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 36),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _BigButton(
            onPressed: _processing ? null : () => _markTaken(reminder),
            color: const Color(0xFF27AE60),
            icon: _processing
                ? const SizedBox(
                    width: 28,
                    height: 28,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2.5),
                  )
                : const Icon(Icons.check_circle_outline,
                    size: 34, color: Colors.white),
            label: 'Tomé el medicamento',
          ),
          const SizedBox(height: 16),
          if (!widget.isCritical)
            _OutlineButton(
              onPressed: _processing ? null : () => _snooze(reminder),
              icon: Icons.snooze,
              label: 'Posponer 30 min',
              color: Colors.white60,
              borderColor: Colors.white24,
            )
          else
            _OutlineButton(
              onPressed: _processing ? null : () => _skip(reminder),
              icon: Icons.cancel_outlined,
              label: 'No puedo tomarlo',
              color: Colors.red.shade300,
              borderColor: Colors.red.shade800,
            ),
        ],
      ),
    );
  }

  Future<void> _markTaken(RemindersTableData reminder) async {
    setState(() => _processing = true);
    try {
      await RecordIntakeUseCase(
        reminderDao: ref.read(reminderDaoProvider),
        intakeDao: ref.read(intakeDaoProvider),
        notificationService: NotificationService.instance,
      ).execute(reminder: reminder, taken: true);
      ref.invalidate(todayRemindersProvider);
      if (mounted) Navigator.of(context).pop();
    } finally {
      if (mounted) setState(() => _processing = false);
    }
  }

  Future<void> _skip(RemindersTableData reminder) async {
    setState(() => _processing = true);
    try {
      await RecordIntakeUseCase(
        reminderDao: ref.read(reminderDaoProvider),
        intakeDao: ref.read(intakeDaoProvider),
        notificationService: NotificationService.instance,
      ).execute(reminder: reminder, taken: false);
      ref.invalidate(todayRemindersProvider);
      if (mounted) Navigator.of(context).pop();
    } finally {
      if (mounted) setState(() => _processing = false);
    }
  }

  Future<void> _snooze(RemindersTableData reminder) async {
    setState(() => _processing = true);
    try {
      final snoozed = await SnoozeReminderUseCase(
        reminderDao: ref.read(reminderDaoProvider),
        notificationService: NotificationService.instance,
      ).execute(
        reminder: reminder,
        isCritical: widget.isCritical,
        medicationName: widget.medicationName,
        isAlertMode: true,
      );
      ref.invalidate(todayRemindersProvider);
      if (!mounted) return;
      if (!snoozed) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Ya se alcanzó el máximo de postposiciones para este recordatorio.'),
          ),
        );
      } else {
        Navigator.of(context).pop();
      }
    } finally {
      if (mounted) setState(() => _processing = false);
    }
  }

  Future<void> _confirmDismiss() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A2A3A),
        title: const Text('¿Cerrar sin registrar?',
            style: TextStyle(color: Colors.white)),
        content: const Text(
          'No quedarán registros de esta toma. '
          'Podés hacerlo desde la pantalla principal.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar',
                style: TextStyle(color: Colors.blue)),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text('Cerrar',
                style: TextStyle(color: Colors.red.shade300)),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) Navigator.of(context).pop();
  }
}

// ─── Widgets auxiliares ───────────────────────────────────────────────────────

class _BigButton extends StatelessWidget {
  const _BigButton({
    required this.onPressed,
    required this.color,
    required this.icon,
    required this.label,
  });

  final VoidCallback? onPressed;
  final Color color;
  final Widget icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 76,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          disabledBackgroundColor: color.withValues(alpha: 0.4),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            icon,
            const SizedBox(width: 12),
            Text(
              label,
              style: const TextStyle(
                  fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

class _OutlineButton extends StatelessWidget {
  const _OutlineButton({
    required this.onPressed,
    required this.icon,
    required this.label,
    required this.color,
    required this.borderColor,
  });

  final VoidCallback? onPressed;
  final IconData icon;
  final String label;
  final Color color;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 64,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: color,
          side: BorderSide(color: borderColor, width: 1.5),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18)),
          textStyle: const TextStyle(fontSize: 19),
        ),
        icon: Icon(icon, size: 28),
        label: Text(label),
      ),
    );
  }
}
