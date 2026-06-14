import 'package:drift/drift.dart';

import 'patients_table.dart';
import 'treatments_table.dart';

class RemindersTable extends Table {
  @override
  String get tableName => 'reminders';

  TextColumn get id          => text()();
  TextColumn get patientId   => text().references(PatientsTable, #id)();
  TextColumn get treatmentId => text().references(TreatmentsTable, #id)();

  DateTimeColumn get scheduledTime => dateTime()();
  // deadline = scheduledTime + ventana (intervalo/2 o 30min para críticos)
  DateTimeColumn get deadlineTime  => dateTime()();

  // 'pending' | 'triggered' | 'snoozed' | 'taken' | 'expired' | 'closed'
  TextColumn get status => text().withDefault(const Constant('pending'))();

  IntColumn get snoozeCount => integer().withDefault(const Constant(0))();

  // ID de regla canónica que generó este horario (ej: 'R01', 'R03')
  TextColumn get ruleId => text()();
  // Explicación en español para mostrar en UI
  TextColumn get ruleExplanation => text()();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}
