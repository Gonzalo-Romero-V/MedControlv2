import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../providers/prescription_flow_provider.dart';

/// Pantalla de captura: punto de entrada del flujo de registro de receta.
/// El usuario elige entre foto (cámara o galería) o ingreso manual.
class PrescriptionCaptureScreen extends ConsumerWidget {
  const PrescriptionCaptureScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(prescriptionFlowProvider);
    final notifier = ref.read(prescriptionFlowProvider.notifier);
    final isParsing = state is PrescriptionFlowParsing;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Registrar medicamento'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 16),
                _InfoBanner(),
                const SizedBox(height: 32),
                _CaptureButton(
                  icon: Icons.camera_alt,
                  label: 'Tomar foto de la receta',
                  sublabel: 'Recomendado — la IA extrae los datos automáticamente',
                  color: Theme.of(context).colorScheme.primary,
                  onTap: isParsing ? null : () => _pickImage(context, ref, notifier, ImageSource.camera),
                ),
                const SizedBox(height: 16),
                _CaptureButton(
                  icon: Icons.photo_library,
                  label: 'Seleccionar de la galería',
                  sublabel: 'Elegir una foto ya tomada',
                  color: Theme.of(context).colorScheme.secondary,
                  onTap: isParsing ? null : () => _pickImage(context, ref, notifier, ImageSource.gallery),
                ),
                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 16),
                TextButton.icon(
                  icon: const Icon(Icons.edit_note),
                  label: const Text('Ingresar datos manualmente'),
                  onPressed: isParsing ? null : notifier.useManualEntry,
                  style: TextButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                  ),
                ),
                if (state is PrescriptionFlowError) ...[
                  const SizedBox(height: 24),
                  _ErrorCard(message: state.message),
                ],
              ],
            ),
          ),
          if (isParsing) const _ParsingOverlay(),
        ],
      ),
    );
  }

  Future<void> _pickImage(
    BuildContext context,
    WidgetRef ref,
    PrescriptionFlowNotifier notifier,
    ImageSource source,
  ) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: source,
      imageQuality: 90,
      maxWidth: 2048,
    );
    if (picked == null) return;
    await notifier.parseImage(File(picked.path));
  }
}

class _InfoBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline,
              color: Theme.of(context).colorScheme.onSecondaryContainer),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'La IA extrae los datos de la receta. Siempre podrás revisar '
              'y corregir antes de guardar.',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSecondaryContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CaptureButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final String sublabel;
  final Color color;
  final VoidCallback? onTap;

  const _CaptureButton({
    required this.icon,
    required this.label,
    required this.sublabel,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: onTap == null ? Colors.grey.shade200 : color.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            border: Border.all(
              color: onTap == null ? Colors.grey.shade300 : color.withValues(alpha: 0.4),
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(icon, size: 36, color: onTap == null ? Colors.grey : color),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: onTap == null ? Colors.grey : null,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      sublabel,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey.shade600,
                          ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios,
                  size: 16, color: Colors.grey.shade400),
            ],
          ),
        ),
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  final String message;
  const _ErrorCard({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline,
              color: Theme.of(context).colorScheme.onErrorContainer),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                  color: Theme.of(context).colorScheme.onErrorContainer),
            ),
          ),
        ],
      ),
    );
  }
}

class _ParsingOverlay extends StatelessWidget {
  const _ParsingOverlay();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black54,
      child: const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 20),
                Text(
                  'Analizando receta…',
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 8),
                Text(
                  'La IA está extrayendo los datos',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
