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

  /// Finds an existing medication for [patientId] matching [name] or [activeIngredient].
  /// Returns null if none found. Used to detect duplicates before saving a new treatment.
  Future<MedicationsTableData?> findDuplicate(
    String patientId,
    String name,
    String? activeIngredient,
  ) async {
    final all = await getByPatient(patientId);
    final nameLower = name.toLowerCase().trim();
    final ingredientLower = activeIngredient?.toLowerCase().trim();
    for (final med in all) {
      if (med.name.toLowerCase().trim() == nameLower) return med;
      if (ingredientLower != null &&
          ingredientLower.isNotEmpty &&
          med.activeIngredient != null &&
          med.activeIngredient!.toLowerCase().trim() == ingredientLower) {
        return med;
      }
    }
    return null;
  }

  Future<void> insertMedication(MedicationsTableCompanion medication) =>
      into(medicationsTable).insert(medication);

  Future<void> updateMedication(MedicationsTableCompanion medication) =>
      (update(medicationsTable)
            ..where((t) => t.id.equals(medication.id.value)))
          .write(medication);
}
