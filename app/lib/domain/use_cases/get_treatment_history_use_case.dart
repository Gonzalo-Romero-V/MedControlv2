import '../../infrastructure/database/app_database.dart';
import '../../infrastructure/database/daos/intake_dao.dart';
import '../../infrastructure/database/daos/medication_dao.dart';
import '../../infrastructure/database/daos/patient_dao.dart';
import '../../infrastructure/database/daos/reminder_dao.dart';
import '../../infrastructure/database/daos/treatment_dao.dart';

class TreatmentHistoryViewModel {
  final TreatmentsTableData treatment;
  final String medicationName;
  final int remindersTotal;
  final int intakesTaken;

  const TreatmentHistoryViewModel({
    required this.treatment,
    required this.medicationName,
    required this.remindersTotal,
    required this.intakesTaken,
  });

  double get adherence =>
      remindersTotal > 0 ? intakesTaken / remindersTotal : 0;

  bool get hasReminders => remindersTotal > 0;
}

class GetTreatmentHistoryUseCase {
  final PatientDao patientDao;
  final TreatmentDao treatmentDao;
  final MedicationDao medicationDao;
  final ReminderDao reminderDao;
  final IntakeDao intakeDao;

  const GetTreatmentHistoryUseCase({
    required this.patientDao,
    required this.treatmentDao,
    required this.medicationDao,
    required this.reminderDao,
    required this.intakeDao,
  });

  Future<List<TreatmentHistoryViewModel>> execute() async {
    final patient = await patientDao.getActivePatient();
    if (patient == null) return [];

    final treatments = await treatmentDao.getAllByPatient(patient.id);
    if (treatments.isEmpty) return [];

    final result = <TreatmentHistoryViewModel>[];
    for (final t in treatments) {
      final medication = await medicationDao.getById(t.medicationId);
      final reminders = await reminderDao.getByTreatment(t.id);
      final taken = await intakeDao.countTaken(t.id);

      result.add(TreatmentHistoryViewModel(
        treatment: t,
        medicationName: medication?.name ?? 'Medicamento',
        remindersTotal: reminders.length,
        intakesTaken: taken,
      ));
    }

    // Active first, then by start date descending
    result.sort((a, b) {
      final aActive = a.treatment.status == 'active' ? 0 : 1;
      final bActive = b.treatment.status == 'active' ? 0 : 1;
      if (aActive != bActive) return aActive - bActive;
      return b.treatment.startDate.compareTo(a.treatment.startDate);
    });

    return result;
  }
}
