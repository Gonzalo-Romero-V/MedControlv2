import 'package:drift/drift.dart';

class PatientsTable extends Table {
  @override
  String get tableName => 'patients';

  TextColumn get id => text()();
  TextColumn get name => text()();
  DateTimeColumn get birthDate => dateTime().nullable()();
  TextColumn get photoPath => text().nullable()();

  // 'autonomous' | 'assisted'
  TextColumn get profileType => text().withDefault(const Constant('autonomous'))();

  BoolColumn get isActive => boolean().withDefault(const Constant(false))();

  // JSON: {"font_size": "large", "high_contrast": false, "large_targets": true}
  TextColumn get accessibilityConfig => text().withDefault(const Constant('{}'))();

  // Horas almacenadas como minutos desde medianoche (ej: 420 = 07:00)
  IntColumn get breakfastTime => integer().withDefault(const Constant(420))();
  IntColumn get lunchTime    => integer().withDefault(const Constant(780))();
  IntColumn get dinnerTime   => integer().withDefault(const Constant(1140))();
  IntColumn get sleepTime    => integer().withDefault(const Constant(1260))();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}
