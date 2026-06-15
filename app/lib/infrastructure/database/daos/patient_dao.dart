import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/patients_table.dart';

part 'patient_dao.g.dart';

@DriftAccessor(tables: [PatientsTable])
class PatientDao extends DatabaseAccessor<AppDatabase> with _$PatientDaoMixin {
  PatientDao(super.db);

  Future<List<PatientsTableData>> getAllPatients() =>
      select(patientsTable).get();

  Future<PatientsTableData?> getActivePatient() =>
      (select(patientsTable)..where((t) => t.isActive.equals(true)))
          .getSingleOrNull();

  Stream<PatientsTableData?> watchActivePatient() =>
      (select(patientsTable)..where((t) => t.isActive.equals(true)))
          .watchSingleOrNull();

  Future<PatientsTableData?> getById(String id) =>
      (select(patientsTable)..where((t) => t.id.equals(id)))
          .getSingleOrNull();

  Future<void> insertPatient(PatientsTableCompanion patient) =>
      into(patientsTable).insert(patient);

  Future<void> setActive(String patientId) => transaction(() async {
        await (update(patientsTable))
            .write(const PatientsTableCompanion(isActive: Value(false)));
        await (update(patientsTable)
              ..where((t) => t.id.equals(patientId)))
            .write(const PatientsTableCompanion(isActive: Value(true)));
      });

  Future<void> updatePatient(PatientsTableCompanion patient) =>
      (update(patientsTable)..where((t) => t.id.equals(patient.id.value)))
          .write(patient);
}
