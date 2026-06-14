import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/reminders_table.dart';

part 'reminder_dao.g.dart';

@DriftAccessor(tables: [RemindersTable])
class ReminderDao extends DatabaseAccessor<AppDatabase>
    with _$ReminderDaoMixin {
  ReminderDao(super.db);

  Future<List<RemindersTableData>> getForDay(
      String patientId, DateTime day) {
    final start = DateTime(day.year, day.month, day.day);
    final end = start.add(const Duration(days: 1));
    return (select(remindersTable)
          ..where((t) =>
              t.patientId.equals(patientId) &
              t.scheduledTime.isBetweenValues(start, end))
          ..orderBy([(t) => OrderingTerm.asc(t.scheduledTime)]))
        .get();
  }

  Future<List<RemindersTableData>> getPendingByPatient(String patientId) =>
      (select(remindersTable)
            ..where((t) =>
                t.patientId.equals(patientId) &
                (t.status.equals('pending') |
                    t.status.equals('triggered') |
                    t.status.equals('snoozed')))
            ..orderBy([(t) => OrderingTerm.asc(t.scheduledTime)]))
          .get();

  Future<void> insertAll(List<RemindersTableCompanion> reminders) =>
      batch((b) => b.insertAll(remindersTable, reminders));

  Future<void> updateStatus(String id, String status,
      {int? snoozeCount}) async {
    await (update(remindersTable)..where((t) => t.id.equals(id))).write(
      RemindersTableCompanion(
        status: Value(status),
        snoozeCount:
            snoozeCount != null ? Value(snoozeCount) : const Value.absent(),
      ),
    );
  }

  Future<List<RemindersTableData>> getByTreatment(String treatmentId) =>
      (select(remindersTable)
            ..where((t) => t.treatmentId.equals(treatmentId))
            ..orderBy([(t) => OrderingTerm.asc(t.scheduledTime)]))
          .get();
}
