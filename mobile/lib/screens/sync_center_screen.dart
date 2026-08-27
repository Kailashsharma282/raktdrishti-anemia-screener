import 'package:flutter/material.dart';
import '../services/sync_service.dart';
import '../database/db_helper.dart';
import '../models/sync_queue_model.dart';

class SyncCenterScreen extends StatefulWidget {
  final SyncService syncService;

  const SyncCenterScreen({Key? key, required this.syncService}) : super(key: key);

  @override
  State<SyncCenterScreen> createState() => _SyncCenterScreenState();
}

class _SyncCenterScreenState extends State<SyncCenterScreen> {
  List<SyncQueueItem> _pendingItems = [];
  String _syncLog = 'Ready to sync.';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadQueue();
  }

  Future<void> _loadQueue() async {
    setState(() => _isLoading = true);
    final items = await LocalDatabase.instance.getPendingSyncItems();
    setState(() {
      _pendingItems = items;
      _isLoading = false;
    });
  }

  void _triggerSync() async {
    setState(() => _syncLog = 'Connecting to FastAPI cloud backend…');
    final success = await widget.syncService.triggerSync();
    setState(() {
      _syncLog = success
          ? '✓ Synchronization completed successfully. All local records flushed to PostgreSQL.'
          : '⚠️ Cloud sync paused. Records remain safely buffered in local SQLite storage.';
    });
    _loadQueue();
  }

  @override
  Widget build(BuildContext context) {
    final isOnline = widget.syncService.isOnline;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Offline Sync Center'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Network Simulation Controller Card (Crucial for Hackathon Demos)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Network Connectivity Simulation',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Toggle network state to demonstrate offline-first resilience & automatic batch sync.',
                      style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                    ),
                    const Divider(height: 20),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        isOnline ? '🌐 Connected to Cloud Server' : '📡 Airplane Mode / Offline Mode',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isOnline ? const Color(0xFF059669) : const Color(0xFFD97706),
                        ),
                      ),
                      subtitle: Text(isOnline ? 'Direct sync enabled' : 'Local SQLite persistence active'),
                      value: isOnline,
                      activeColor: const Color(0xFF059669),
                      onChanged: (val) {
                        widget.syncService.setOnlineStatus(val);
                        setState(() {});
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Sync Queue Summary Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Buffered Local Queue', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: _pendingItems.isEmpty
                                ? const Color(0xFF10B981).withOpacity(0.15)
                                : const Color(0xFFF59E0B).withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${_pendingItems.length} Pending Records',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              color: _pendingItems.isEmpty ? const Color(0xFF047857) : const Color(0xFFB45309),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F172A),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _syncLog,
                        style: const TextStyle(color: Color(0xFF38BDF8), fontFamily: 'monospace', fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Trigger Manual Sync Button
            ElevatedButton.icon(
              icon: const Icon(Icons.cloud_upload_rounded),
              label: const Text('Flush Sync Queue Now'),
              onPressed: isOnline ? _triggerSync : null,
            ),
          ],
        ),
      ),
    );
  }
}
