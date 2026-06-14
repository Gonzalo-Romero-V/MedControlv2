import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/medications_table.dart';

part 'medication_dao.g.dart';

@DriftAccessor(tables: [MedicationsTable])
class MedicationDao extends DatabaseAccessor<AppDatabase>
    with _$MedicationDaoMixin {
  MedicationDao(super.db);

  Future<List<MedicationsTableData>> getByPatient(String patientId) =>
      (select(medicationsTable)
            ..where((t) => t.patientId.equals(patientId)))
          .get();

  Future<MedicationsTableData?> getById(String id) =>
      (select(medicationsTable)..where((t) => t.id.equals(id)))
          .getSingleOrNull();

  Future<void> insertMedication(MedicationsTableCompanion medication) =>
      into(medicationsTable).insert(medication);

  Future<void> updateMedication(MedicationsTableCompanion medication) =>
      (update(medicationsTable)
            ..where((t) => t.id.equals(medication.id.value)))
          .write(medication);
}
