import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'tables/patients_table.dart';
import 'tables/medications_table.dart';
import 'tables/treatments_table.dart';
import 'tables/reminders_table.dart';
import 'tables/intakes_table.dart';
import 'daos/patient_dao.dart';
import 'daos/medication_dao.dart';
import 'daos/treatment_dao.dart';
import 'daos/reminder_dao.dart';
import 'daos/intake_dao.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    PatientsTable,
    MedicationsTable,
    TreatmentsTable,
    RemindersTable,
    IntakesTable,
  ],
  daos: [
    PatientDao,
    MedicationDao,
    TreatmentDao,
    ReminderDao,
    IntakeDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  static QueryExecutor _openConnection() {
    return driftDatabase(name: 'med_control.db');
  }
}
