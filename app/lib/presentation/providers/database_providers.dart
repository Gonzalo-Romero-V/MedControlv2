import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../infrastructure/database/app_database.dart';
import '../../infrastructure/database/daos/medication_dao.dart';
import '../../infrastructure/database/daos/patient_dao.dart';
import '../../infrastructure/database/daos/treatment_dao.dart';

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

final patientDaoProvider = Provider<PatientDao>(
  (ref) => ref.watch(appDatabaseProvider).patientDao,
);

final medicationDaoProvider = Provider<MedicationDao>(
  (ref) => ref.watch(appDatabaseProvider).medicationDao,
);

final treatmentDaoProvider = Provider<TreatmentDao>(
  (ref) => ref.watch(appDatabaseProvider).treatmentDao,
);
