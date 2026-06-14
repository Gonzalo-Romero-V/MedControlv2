import 'package:drift/drift.dart';

import 'patients_table.dart';

class MedicationsTable extends Table {
  @override
  String get tableName => 'medications';

  TextColumn get id         => text()();
  TextColumn get patientId  => text().references(PatientsTable, #id)();
  TextColumn get name       => text()();
  TextColumn get activeIngredient => text().nullable()();

  // 'tablet' | 'capsule' | 'syrup' | 'injectable' | 'topical' | 'drops' | 'inhaler' | 'other'
  TextColumn get presentation => text().withDefault(const Constant('tablet'))();

  TextColumn get boxPhotoPath => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}
