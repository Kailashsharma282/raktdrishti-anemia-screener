import 'dart:async';
import '../database/db_helper.dart';
import '../models/patient_model.dart';
import '../models/screening_model.dart';
import '../models/referral_model.dart';
import 'api_service.dart';

class SyncService {
  final LocalDatabase db = LocalDatabase.instance;
  final ApiService api;

  bool _isOnline = true;
  bool _isSyncing = false;

  final StreamController<String> _syncStatusController = StreamController<String>.broadcast();
  Stream<String> get syncStatusStream => _syncStatusController.stream;

  SyncService({required this.api});

  bool get isOnline => _isOnline;
  bool get isSyncing => _isSyncing;

  void setOnlineStatus(bool online) {
    _isOnline = online;
    _syncStatusController.add(online ? 'ONLINE' : 'OFFLINE');
    if (online) {
      triggerSync();
    }
  }

  Future<int> getPendingSyncCount() async {
    final pendingItems = await db.getPendingSyncItems();
    return pendingItems.length;
  }

  Future<bool> triggerSync() async {
    if (!_isOnline || _isSyncing) return false;

    _isSyncing = true;
    _syncStatusController.add('SYNCING');

    try {
      final patients = (await db.getPatients()).where((p) => p.syncStatus == 'PENDING').toList();
      final screenings = (await db.getScreenings()).where((s) => s.syncStatus == 'PENDING').toList();
      final referrals = (await db.getReferrals()).where((r) => r.syncStatus == 'PENDING').toList();

      final totalPending = patients.length + screenings.length + referrals.length;
      if (totalPending == 0) {
        _isSyncing = false;
        _syncStatusController.add('SYNCED');
        return true;
      }

      _syncStatusController.add('$totalPending records waiting to sync');

      final success = await api.syncBatch(
        patients: patients,
        screenings: screenings,
        referrals: referrals,
      );

      if (success) {
        await db.clearSyncedQueue();
        _syncStatusController.add('Sync completed');
      } else {
        _syncStatusController.add('Sync paused (Network error)');
      }

      _isSyncing = false;
      return success;
    } catch (_) {
      _isSyncing = false;
      _syncStatusController.add('Sync failed');
      return false;
    }
  }
}
