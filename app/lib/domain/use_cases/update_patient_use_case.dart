import 'package:drift/drift.dart';

import '../entities/accessibility_config.dart';
import '../entities/med_time.dart';
import '../../infrastructure/database/app_database.dart';
import '../../infrastructure/database/daos/patient_dao.dart';

class UpdatePatientUseCase {
  final PatientDao patientDao;

  const UpdatePatientUseCase({required this.patientDao});

  Future<void> execute({
    required String patientId,
    String? name,
    String? profileType,
    MedTime? breakfastTime,
    MedTime? lunchTime,
    MedTime? dinnerTime,
    MedTime? sleepTime,
    AccessibilityConfig? accessibilityConfig,
  }) async {
    await patientDao.updatePatient(PatientsTableCompanion(
      id: Value(patientId),
      name: name != null ? Value(name) : const Value.absent(),
      profileType:
          profileType != null ? Value(profileType) : const Value.absent(),
      breakfastTime: breakfastTime != null
          ? Value(breakfastTime.totalMinutes)
          : const Value.absent(),
      lunchTime: lunchTime != null
          ? Value(lunchTime.totalMinutes)
          : const Value.absent(),
      dinnerTime: dinnerTime != null
          ? Value(dinnerTime.totalMinutes)
          : const Value.absent(),
      sleepTime: sleepTime != null
          ? Value(sleepTime.totalMinutes)
          : const Value.absent(),
      accessibilityConfig: accessibilityConfig != null
          ? Value(accessibilityConfig.toJson())
          : const Value.absent(),
    ));
  }
}
