import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/intakes_table.dart';
import '../tables/reminders_table.dart';

part 'intake_dao.g.dart';

@DriftAccessor(tables: [IntakesTable, RemindersTable])
class IntakeDao extends DatabaseAccessor<AppDatabase> with _$IntakeDaoMixin {
  IntakeDao(super.db);

  Future<void> insertIntake(IntakesTableCompanion intake) =>
      into(intakesTable).insert(intake);

  Future<List<IntakesTableData>> getByReminder(String reminderId) =>
      (select(intakesTable)
            ..where((t) => t.reminderId.equals(reminderId)))
          .get();

  Future<List<IntakesTableData>> getByTreatment(String treatmentId) {
    final query = select(intakesTable).join([
      innerJoin(
        remindersTable,
        remindersTable.id.equalsExp(intakesTable.reminderId),
      ),
    ])
      ..where(remindersTable.treatmentId.equals(treatmentId))
      ..orderBy([OrderingTerm.asc(intakesTable.recordedAt)]);

    return query.map((row) => row.readTable(intakesTable)).get();
  }

  Future<int> countTaken(String treatmentId) async {
    final query = select(intakesTable).join([
      innerJoin(
        remindersTable,
        remindersTable.id.equalsExp(intakesTable.reminderId),
      ),
    ])
      ..where(
        remindersTable.treatmentId.equals(treatmentId) &
            (intakesTable.result.equals('taken') |
                intakesTable.result.equals('taken_late')),
      );

    final rows = await query.get();
    return rows.length;
  }
}
