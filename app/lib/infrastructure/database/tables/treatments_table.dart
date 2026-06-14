import 'package:drift/drift.dart';

import 'patients_table.dart';
import 'medications_table.dart';

class TreatmentsTable extends Table {
  @override
  String get tableName => 'treatments';

  TextColumn get id           => text()();
  TextColumn get patientId    => text().references(PatientsTable, #id)();
  TextColumn get medicationId => text().references(MedicationsTable, #id)();

  // Dosis
  RealColumn get doseAmount => real()();
  // 'tablets' | 'ml' | 'mg' | 'drops' | 'puff' | 'application'
  TextColumn get doseUnit => text()();

  // 'every_n_hours' | 'n_times_day' | 'on_demand' | 'tapering'
  TextColumn get frequencyType  => text()();
  IntColumn  get frequencyValue => integer().nullable()();

  // 'oral' | 'topical' | 'inhaled' | 'sublingual' | 'rectal' | 'other'
  TextColumn get route => text().withDefault(const Constant('oral'))();

  TextColumn get specialInstructions => text().nullable()();

  // 'by_duration' | 'by_quantity' | 'indefinite' | 'on_demand'
  TextColumn get endCriterionType => text()();
  IntColumn  get durationDays     => integer().nullable()();
  IntColumn  get totalDoses       => integer().nullable()();

  DateTimeColumn get startDate          => dateTime()();
  DateTimeColumn get calculatedEndDate  => dateTime().nullable()();

  // Medicamento de ventana terapéutica estrecha → ventana posposición fija 30min
  BoolColumn get isCritical => boolean().withDefault(const Constant(false))();

  // 'active' | 'completed' | 'suspended' | 'abandoned' | 'expired'
  TextColumn get status => text().withDefault(const Constant('active'))();

  // 'ocr_ai' | 'manual'
  TextColumn get origin => text().withDefault(const Constant('manual'))();

  TextColumn get prescriptionImagePath => text().nullable()();
  TextColumn get prescriptionOcrText   => text().nullable()();
  TextColumn get notes                 => text().nullable()();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get endedAt   => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
