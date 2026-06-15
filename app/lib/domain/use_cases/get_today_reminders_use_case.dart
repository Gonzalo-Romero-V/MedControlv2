import '../../infrastructure/database/app_database.dart';
import '../../infrastructure/database/daos/medication_dao.dart';
import '../../infrastructure/database/daos/patient_dao.dart';
import '../../infrastructure/database/daos/reminder_dao.dart';
import '../../infrastructure/database/daos/treatment_dao.dart';

class ReminderViewModel {
  final RemindersTableData reminder;
  final String medicationName;
  final bool isCritical;

  const ReminderViewModel({
    required this.reminder,
    required this.medicationName,
    required this.isCritical,
  });
}

class GetTodayRemindersUseCase {
  final PatientDao patientDao;
  final ReminderDao reminderDao;
  final TreatmentDao treatmentDao;
  final MedicationDao medicationDao;

  const GetTodayRemindersUseCase({
    required this.patientDao,
    required this.reminderDao,
    required this.treatmentDao,
    required this.medicationDao,
  });

  Future<List<ReminderViewModel>> execute() async {
    final patient = await patientDao.getActivePatient();
    if (patient == null) return [];

    final reminders = await reminderDao.getForDay(patient.id, DateTime.now());
    if (reminders.isEmpty) return [];

    final treatments = await treatmentDao.getActiveByPatient(patient.id);
    final treatmentMap = {for (final t in treatments) t.id: t};

    // Load medication names (one query per unique medicationId)
    final medNameMap = <String, String>{};
    for (final t in treatments) {
      if (!medNameMap.containsKey(t.medicationId)) {
        final med = await medicationDao.getById(t.medicationId);
        if (med != null) medNameMap[t.medicationId] = med.name;
      }
    }

    return reminders.map((r) {
      final treatment = treatmentMap[r.treatmentId];
      final medName = treatment != null
          ? (medNameMap[treatment.medicationId] ?? 'Medicamento')
          : 'Medicamento';
      return ReminderViewModel(
        reminder: r,
        medicationName: medName,
        isCritical: treatment?.isCritical ?? false,
      );
    }).toList();
  }
}
