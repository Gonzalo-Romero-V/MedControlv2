import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/accessibility_config.dart';
import '../../domain/entities/med_time.dart';
import '../../domain/entities/patient_profile.dart';
import '../../domain/use_cases/update_patient_use_case.dart';
import '../../infrastructure/database/app_database.dart';
import 'database_providers.dart';

export '../../domain/entities/accessibility_config.dart';

final updatePatientUseCaseProvider = Provider<UpdatePatientUseCase>(
  (ref) => UpdatePatientUseCase(patientDao: ref.watch(patientDaoProvider)),
);

final activePatientProvider = StreamProvider<PatientsTableData?>((ref) {
  return ref.watch(patientDaoProvider).watchActivePatient();
});

final patientProfileProvider = Provider<PatientProfile>((ref) {
  final patient = ref.watch(activePatientProvider).valueOrNull;
  if (patient == null) return PatientProfile.defaults;
  return PatientProfile(
    breakfastTime: MedTime.fromMinutes(patient.breakfastTime),
    lunchTime: MedTime.fromMinutes(patient.lunchTime),
    dinnerTime: MedTime.fromMinutes(patient.dinnerTime),
    sleepTime: MedTime.fromMinutes(patient.sleepTime),
  );
});

final accessibilityConfigProvider = Provider<AccessibilityConfig>((ref) {
  final patient = ref.watch(activePatientProvider).valueOrNull;
  if (patient == null) return const AccessibilityConfig();
  return AccessibilityConfig.fromJson(patient.accessibilityConfig);
});

final isAssistedModeProvider = Provider<bool>((ref) {
  final patient = ref.watch(activePatientProvider).valueOrNull;
  return patient?.profileType == 'assisted';
});

final reduceAnimationsProvider = Provider<bool>((ref) {
  return ref.watch(accessibilityConfigProvider).reduceAnimations;
});

final appThemeProvider = Provider<ThemeData>((ref) {
  final config = ref.watch(accessibilityConfigProvider);
  const seedColor = Color(0xFF1976D2);

  final colorScheme = config.highContrast
      ? const ColorScheme.light(
          primary: Colors.black,
          onPrimary: Colors.white,
          secondary: Colors.black87,
          onSecondary: Colors.white,
          surface: Colors.white,
          onSurface: Colors.black,
          error: Colors.red,
          onError: Colors.white,
          primaryContainer: Color(0xFFE0E0E0),
          onPrimaryContainer: Colors.black,
          secondaryContainer: Color(0xFFEEEEEE),
          onSecondaryContainer: Colors.black,
          inversePrimary: Colors.white,
        )
      : ColorScheme.fromSeed(seedColor: seedColor);

  final pageTransitionsTheme = config.reduceAnimations
      ? const PageTransitionsTheme(builders: {
          TargetPlatform.android: _InstantPageTransitionsBuilder(),
          TargetPlatform.iOS: _InstantPageTransitionsBuilder(),
        })
      : const PageTransitionsTheme();

  return ThemeData(
    colorScheme: colorScheme,
    useMaterial3: true,
    textTheme: const TextTheme().apply(fontSizeFactor: config.fontSizeFactor),
    materialTapTargetSize: config.largeTargets
        ? MaterialTapTargetSize.padded
        : MaterialTapTargetSize.shrinkWrap,
    pageTransitionsTheme: pageTransitionsTheme,
  );
});

// Instant (no-animation) page transition for reduceAnimations mode.
class _InstantPageTransitionsBuilder extends PageTransitionsBuilder {
  const _InstantPageTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) =>
      child;
}
