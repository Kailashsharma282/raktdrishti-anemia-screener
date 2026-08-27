import '../database/db_helper.dart';
import '../models/screening_model.dart';
import '../services/sync_service.dart';

class ScreeningRepository {
  final LocalDatabase db = LocalDatabase.instance;
  final SyncService syncService;

  ScreeningRepository({required this.syncService});

  Future<List<ScreeningModel>> getScreenings({String? patientId}) async {
    return await db.getScreenings(patientId: patientId);
  }

  Future<void> saveScreening(ScreeningModel screening) async {
    await db.insertScreening(screening);
    if (syncService.isOnline) {
      syncService.triggerSync();
    }
  }
}
