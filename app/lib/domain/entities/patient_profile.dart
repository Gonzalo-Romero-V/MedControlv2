import 'package:equatable/equatable.dart';

import 'med_time.dart';

/// Perfil del paciente relevante para el motor de inferencia.
/// Las horas de comida y sueño son entradas del sistema de reglas.
class PatientProfile extends Equatable {
  final MedTime breakfastTime;
  final MedTime lunchTime;
  final MedTime dinnerTime;
  final MedTime sleepTime;

  const PatientProfile({
    required this.breakfastTime,
    required this.lunchTime,
    required this.dinnerTime,
    required this.sleepTime,
  });

  /// Perfil por defecto cuando no hay configuración del paciente
  static const PatientProfile defaults = PatientProfile(
    breakfastTime: MedTime(7, 0),
    lunchTime: MedTime(13, 0),
    dinnerTime: MedTime(19, 0),
    sleepTime: MedTime(21, 0),
  );

  List<MedTime> get mealTimes => [breakfastTime, lunchTime, dinnerTime];

  @override
  List<Object?> get props =>
      [breakfastTime, lunchTime, dinnerTime, sleepTime];
}
