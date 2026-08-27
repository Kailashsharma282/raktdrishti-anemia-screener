import '../database/db_helper.dart';
import '../models/patient_model.dart';
import '../services/sync_service.dart';

class PatientRepository {
  final LocalDatabase db = LocalDatabase.instance;
  final SyncService syncService;

  PatientRepository({required this.syncService});

  Future<List<PatientModel>> getPatients({String? search, String? village}) async {
    return await db.getPatients(search: search, village: village);
  }

  Future<PatientModel?> getPatientById(String id) async {
    return await db.getPatientById(id);
  }

  Future<void> registerPatient(PatientModel patient) async {
    await db.insertPatient(patient);
    if (syncService.isOnline) {
      syncService.triggerSync();
    }
  }
}
