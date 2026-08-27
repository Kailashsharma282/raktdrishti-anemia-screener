import '../database/db_helper.dart';
import '../models/referral_model.dart';
import '../services/sync_service.dart';

class ReferralRepository {
  final LocalDatabase db = LocalDatabase.instance;
  final SyncService syncService;

  ReferralRepository({required this.syncService});

  Future<List<ReferralModel>> getReferrals({String? status}) async {
    return await db.getReferrals(status: status);
  }

  Future<void> saveReferral(ReferralModel referral) async {
    await db.insertReferral(referral);
    if (syncService.isOnline) {
      syncService.triggerSync();
    }
  }

  Future<void> updateReferralStatus(String referralId, String newStatus, {double? hb, String? notes}) async {
    final refs = await db.getReferrals();
    final idx = refs.indexWhere((r) => r.id == referralId);
    if (idx >= 0) {
      final old = refs[idx];
      final updated = ReferralModel(
        id: old.id,
        screeningId: old.screeningId,
        patientId: old.patientId,
        patientName: old.patientName,
        patientCode: old.patientCode,
        workerId: old.workerId,
        referralFacility: old.referralFacility,
        urgency: old.urgency,
        status: newStatus,
        labConfirmedHb: hb ?? old.labConfirmedHb,
        clinicalNotes: notes ?? old.clinicalNotes,
        prescribedTreatment: old.prescribedTreatment,
        syncStatus: 'PENDING',
        createdAt: old.createdAt,
        updatedAt: DateTime.now(),
      );
      await db.insertReferral(updated);
      if (syncService.isOnline) {
        syncService.triggerSync();
      }
    }
  }
}
