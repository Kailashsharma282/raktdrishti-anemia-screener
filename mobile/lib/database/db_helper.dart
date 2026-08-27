import 'dart:async';
import '../models/patient_model.dart';
import '../models/screening_model.dart';
import '../models/referral_model.dart';
import '../models/sync_queue_model.dart';

class LocalDatabase {
  static final LocalDatabase instance = LocalDatabase._init();
  LocalDatabase._init();

  // In-memory caching & offline mirror
  final List<PatientModel> _patients = [];
  final List<ScreeningModel> _screenings = [];
  final List<ReferralModel> _referrals = [];
  final List<SyncQueueItem> _syncQueue = [];

  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    _seedDefaultOfflineData();
    _initialized = true;
  }

  void _seedDefaultOfflineData() {
    final now = DateTime.now();

    // Default seeded patient for offline testing
    final p1 = PatientModel(
      id: 'p-12903-abcd-4902-8821-ananya-rao',
      patientCode: 'RD-2026-0042',
      workerId: 'w-asha-001-varanasi',
      name: 'Ananya Rao',
      age: 24,
      gender: 'female',
      pregnancyStatus: 'pregnant',
      phone: '+91-9876543210',
      village: 'Demo Village',
      notes: 'Second trimester ANC visit. Reports mild fatigue.',
      syncStatus: 'SYNCED',
      createdAt: now.subtract(const Duration(days: 5)),
      updatedAt: now.subtract(const Duration(days: 5)),
      latestRiskCategory: 'MODERATE',
      latestRiskScore: 0.72,
      screeningsCount: 1,
    );

    final s1 = ScreeningModel(
      id: 'sc-001-ananya-rao-moderate',
      patientId: p1.id,
      patientName: p1.name,
      workerId: 'w-asha-001-varanasi',
      screeningDate: now.subtract(const Duration(days: 5)),
      deviceId: 'Samsung-Galaxy-A14',
      conjunctivaQuality: 88.5,
      nailQuality: 92.0,
      palmQuality: 86.0,
      overallQuality: 88.8,
      finalRiskCategory: 'MODERATE',
      riskScore: 0.72,
      confidence: 0.81,
      modelVersion: 'v1.0.0-mvp-demo',
      status: 'completed',
      syncStatus: 'SYNCED',
      referralId: 'ref-001-ananya-rao',
      referralStatus: 'Referred',
      createdAt: now.subtract(const Duration(days: 5)),
    );

    final r1 = ReferralModel(
      id: 'ref-001-ananya-rao',
      screeningId: s1.id,
      patientId: p1.id,
      patientName: p1.name,
      patientCode: p1.patientCode,
      workerId: 'w-asha-001-varanasi',
      referralFacility: 'Community Health Centre (CHC) Shivpur',
      urgency: 'high',
      status: 'Referred',
      clinicalNotes: 'Referred for confirmatory CBC and Serum Ferritin testing.',
      syncStatus: 'SYNCED',
      createdAt: now.subtract(const Duration(days: 5)),
      updatedAt: now.subtract(const Duration(days: 5)),
    );

    _patients.add(p1);
    _screenings.add(s1);
    _referrals.add(r1);
  }

  // --- Patients CRUD ---
  Future<List<PatientModel>> getPatients({String? search, String? village}) async {
    await init();
    return _patients.where((p) {
      if (search != null && search.isNotEmpty) {
        final q = search.toLowerCase();
        final match = p.name.toLowerCase().contains(q) ||
            p.patientCode.toLowerCase().contains(q) ||
            (p.phone ?? '').contains(q);
        if (!match) return false;
      }
      if (village != null && village.isNotEmpty) {
        if (p.village != village) return false;
      }
      return true;
    }).toList();
  }

  Future<PatientModel?> getPatientById(String id) async {
    await init();
    try {
      return _patients.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> insertPatient(PatientModel patient, {bool queueSync = true}) async {
    await init();
    final idx = _patients.indexWhere((p) => p.id == patient.id);
    if (idx >= 0) {
      _patients[idx] = patient;
    } else {
      _patients.insert(0, patient);
    }

    if (queueSync && patient.syncStatus == 'PENDING') {
      _syncQueue.add(
        SyncQueueItem(
          id: 'sq-${patient.id}',
          entityType: 'Patient',
          entityId: patient.id,
          action: 'CREATE',
          payload: patient.toMap(),
          createdAt: DateTime.now(),
        ),
      );
    }
  }

  // --- Screenings CRUD ---
  Future<List<ScreeningModel>> getScreenings({String? patientId}) async {
    await init();
    if (patientId != null) {
      return _screenings.where((s) => s.patientId == patientId).toList();
    }
    return List.from(_screenings);
  }

  Future<void> insertScreening(ScreeningModel screening, {bool queueSync = true}) async {
    await init();
    _screenings.insert(0, screening);

    // Update patient latest stats
    final pIdx = _patients.indexWhere((p) => p.id == screening.patientId);
    if (pIdx >= 0) {
      final p = _patients[pIdx];
      _patients[pIdx] = PatientModel(
        id: p.id,
        patientCode: p.patientCode,
        workerId: p.workerId,
        name: p.name,
        age: p.age,
        gender: p.gender,
        pregnancyStatus: p.pregnancyStatus,
        phone: p.phone,
        village: p.village,
        notes: p.notes,
        syncStatus: p.syncStatus,
        createdAt: p.createdAt,
        updatedAt: DateTime.now(),
        latestRiskCategory: screening.finalRiskCategory,
        latestRiskScore: screening.riskScore,
        screeningsCount: p.screeningsCount + 1,
      );
    }

    if (queueSync && screening.syncStatus == 'PENDING') {
      _syncQueue.add(
        SyncQueueItem(
          id: 'sq-${screening.id}',
          entityType: 'Screening',
          entityId: screening.id,
          action: 'CREATE',
          payload: screening.toMap(),
          createdAt: DateTime.now(),
        ),
      );
    }
  }

  // --- Referrals CRUD ---
  Future<List<ReferralModel>> getReferrals({String? status}) async {
    await init();
    if (status != null) {
      return _referrals.where((r) => r.status == status).toList();
    }
    return List.from(_referrals);
  }

  Future<void> insertReferral(ReferralModel referral, {bool queueSync = true}) async {
    await init();
    final idx = _referrals.indexWhere((r) => r.id == referral.id);
    if (idx >= 0) {
      _referrals[idx] = referral;
    } else {
      _referrals.insert(0, referral);
    }

    if (queueSync && referral.syncStatus == 'PENDING') {
      _syncQueue.add(
        SyncQueueItem(
          id: 'sq-${referral.id}',
          entityType: 'Referral',
          entityId: referral.id,
          action: 'CREATE',
          payload: referral.toMap(),
          createdAt: DateTime.now(),
        ),
      );
    }
  }

  // --- Sync Queue ---
  Future<List<SyncQueueItem>> getPendingSyncItems() async {
    await init();
    return _syncQueue.where((item) => item.status == 'PENDING').toList();
  }

  Future<void> clearSyncedQueue() async {
    await init();
    _syncQueue.clear();
    // Mark all items as SYNCED
    for (int i = 0; i < _patients.length; i++) {
      if (_patients[i].syncStatus == 'PENDING') {
        _patients[i] = PatientModel(
          id: _patients[i].id,
          patientCode: _patients[i].patientCode,
          workerId: _patients[i].workerId,
          name: _patients[i].name,
          age: _patients[i].age,
          gender: _patients[i].gender,
          pregnancyStatus: _patients[i].pregnancyStatus,
          phone: _patients[i].phone,
          village: _patients[i].village,
          notes: _patients[i].notes,
          syncStatus: 'SYNCED',
          createdAt: _patients[i].createdAt,
          updatedAt: _patients[i].updatedAt,
          latestRiskCategory: _patients[i].latestRiskCategory,
          latestRiskScore: _patients[i].latestRiskScore,
          screeningsCount: _patients[i].screeningsCount,
        );
      }
    }
  }

  Future<void> resetToDemo() async {
    _patients.clear();
    _screenings.clear();
    _referrals.clear();
    _syncQueue.clear();
    _seedDefaultOfflineData();
  }
}
