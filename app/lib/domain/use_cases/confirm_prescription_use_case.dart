import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../entities/parsed_prescription.dart';
import '../entities/treatment_facts.dart';
import '../../infrastructure/database/app_database.dart';
import '../../infrastructure/database/daos/medication_dao.dart';
import '../../infrastructure/database/daos/patient_dao.dart';
import '../../infrastructure/database/daos/treatment_dao.dart';

/// Persiste una receta revisada y aprobada por el usuario como Medicamento + Tratamiento en SQLite.
///
/// Garantía: solo se llama después de que el usuario haya revisado y aprobado
/// explícitamente los datos en PrescriptionReviewScreen y ScheduleReviewScreen.
/// La programación de recordatorios es responsabilidad de Phase 5.
class ConfirmPrescriptionUseCase {
  final PatientDao patientDao;
  final MedicationDao medicationDao;
  final TreatmentDao treatmentDao;
  final _uuid = const Uuid();

  const ConfirmPrescriptionUseCase({
    required this.patientDao,
    required this.medicationDao,
    required this.treatmentDao,
  });

  /// Retorna el ID del tratamiento y del paciente activo.
  Future<({String treatmentId, String patientId})> execute(
    ParsedPrescription prescription, {
    DateTime? startDate,
  }) async {
    final patientId = await _ensureActivePatient();
    final medicationId = await _createMedication(prescription, patientId);
    final treatmentId = await _createTreatment(
      prescription,
      patientId,
      medicationId,
      startDate ?? DateTime.now(),
    );
    return (treatmentId: treatmentId, patientId: patientId);
  }

  Future<String> _ensureActivePatient() async {
    final existing = await patientDao.getActivePatient();
    if (existing != null) return existing.id;

    final id = _uuid.v4();
    await patientDao.insertPatient(PatientsTableCompanion(
      id: Value(id),
      name: const Value('Paciente principal'),
      isActive: const Value(true),
    ));
    return id;
  }

  Future<String> _createMedication(
    ParsedPrescription prescription,
    String patientId,
  ) async {
    final id = _uuid.v4();
    await medicationDao.insertMedication(MedicationsTableCompanion(
      id: Value(id),
      patientId: Value(patientId),
      name: Value(prescription.medicationName ?? 'Medicamento sin nombre'),
      activeIngredient: Value(prescription.activeIngredient),
      presentation: const Value('tablet'),
    ));
    return id;
  }

  Future<String> _createTreatment(
    ParsedPrescription prescription,
    String patientId,
    String medicationId,
    DateTime startDate,
  ) async {
    final id = _uuid.v4();
    final endCriterion = prescription.endCriterionType ?? 'indefinite';
    final calculatedEnd =
        _calculateEndDate(startDate, prescription, endCriterion);

    await treatmentDao.insertTreatment(TreatmentsTableCompanion(
      id: Value(id),
      patientId: Value(patientId),
      medicationId: Value(medicationId),
      doseAmount: Value(prescription.doseAmount ?? 1.0),
      doseUnit: Value(prescription.doseUnit ?? 'tablets'),
      frequencyType: Value(_mapFrequencyType(prescription.frequencyType)),
      frequencyValue: Value(prescription.frequencyValue),
      route: Value(prescription.route ?? 'oral'),
      specialInstructions: Value(prescription.specialInstructions),
      endCriterionType: Value(endCriterion),
      durationDays: Value(prescription.durationDays),
      totalDoses: Value(prescription.totalDoses),
      startDate: Value(startDate),
      calculatedEndDate: Value(calculatedEnd),
      isCritical: Value(prescription.isCritical),
      status: const Value('active'),
      origin: Value(
        prescription.source == PrescriptionSource.cloudVisionGemini
            ? 'ocr_ai'
            : 'manual',
      ),
      prescriptionOcrText: Value(
        prescription.rawOcrText.isNotEmpty ? prescription.rawOcrText : null,
      ),
    ));
    return id;
  }

  String _mapFrequencyType(FrequencyType? type) {
    switch (type) {
      case FrequencyType.everyNHours:
        return 'every_n_hours';
      case FrequencyType.nTimesDay:
        return 'n_times_day';
      case FrequencyType.onDemand:
        return 'on_demand';
      case FrequencyType.tapering:
        return 'tapering';
      case null:
        return 'on_demand';
    }
  }

  DateTime? _calculateEndDate(
    DateTime start,
    ParsedPrescription p,
    String endCriterion,
  ) {
    if (endCriterion == 'por_duracion' && p.durationDays != null) {
      return start.add(Duration(days: p.durationDays!));
    }
    return null;
  }
}
