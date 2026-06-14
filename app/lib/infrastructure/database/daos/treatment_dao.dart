import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/treatments_table.dart';

part 'treatment_dao.g.dart';

@DriftAccessor(tables: [TreatmentsTable])
class TreatmentDao extends DatabaseAccessor<AppDatabase>
    with _$TreatmentDaoMixin {
  TreatmentDao(super.db);

  Future<List<TreatmentsTableData>> getActiveByPatient(String patientId) =>
      (select(treatmentsTable)
            ..where((t) =>
                t.patientId.equals(patientId) &
                t.status.equals('active')))
          .get();

  Future<List<TreatmentsTableData>> getAllByPatient(String patientId) =>
      (select(treatmentsTable)
            ..where((t) => t.patientId.equals(patientId)))
          .get();

  Future<List<TreatmentsTableData>> getConflicting(
      String patientId, String medicationId) =>
      (select(treatmentsTable)
            ..where((t) =>
                t.patientId.equals(patientId) &
                t.medicationId.equals(medicationId) &
                (t.status.equals('active') | t.status.equals('suspended'))))
          .get();

  Future<void> insertTreatment(TreatmentsTableCompanion treatment) =>
      into(treatmentsTable).insert(treatment);

  Future<void> updateStatus(String id, String status,
      {DateTime? endedAt}) async {
    await (update(treatmentsTable)..where((t) => t.id.equals(id))).write(
      TreatmentsTableCompanion(
        status: Value(status),
        endedAt: Value(endedAt),
      ),
    );
  }
}
