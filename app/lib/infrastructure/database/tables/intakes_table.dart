import 'package:drift/drift.dart';

import 'reminders_table.dart';

class IntakesTable extends Table {
  @override
  String get tableName => 'intakes';

  TextColumn get id         => text()();
  TextColumn get reminderId => text().references(RemindersTable, #id)();

  // 'taken' | 'taken_late' | 'skipped' | 'snooze_expired'
  TextColumn get result => text()();

  // Hora real en que el usuario tomó (null si skipped/expired)
  DateTimeColumn get actualTime   => dateTime().nullable()();
  IntColumn      get minutesLate  => integer().nullable()();

  DateTimeColumn get recordedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}
