import 'package:flutter/material.dart';
import '../core/constants/app_constants.dart';
import '../widgets/metric_card.dart';
import '../widgets/offline_indicator.dart';
import '../services/auth_service.dart';
import '../services/sync_service.dart';
import '../services/api_service.dart';
import '../database/db_helper.dart';
import 'patient_list_screen.dart';
import 'register_patient_screen.dart';
import 'start_screening_screen.dart';
import 'screening_history_screen.dart';
import 'referral_screen.dart';
import 'sync_center_screen.dart';
import 'worker_profile_screen.dart';
import 'settings_screen.dart';
import 'demo_mode_screen.dart';

class WorkerHomeScreen extends StatefulWidget {
  const WorkerHomeScreen({Key? key}) : super(key: key);

  @override
  State<WorkerHomeScreen> createState() => _WorkerHomeScreenState();
}

class _WorkerHomeScreenState extends State<WorkerHomeScreen> {
  late AuthService _authService;
  late SyncService _syncService;
  final LocalDatabase _db = LocalDatabase.instance;

  int _totalScreenings = 0;
  int _highRiskCount = 0;
  int _pendingSync = 0;
  int _referralsCount = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    final api = ApiService();
    _authService = AuthService(api: api);
    _syncService = SyncService(api: api);
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() => _isLoading = true);
    final screenings = await _db.getScreenings();
    final referrals = await _db.getReferrals();
    final pendingItems = await _db.getPendingSyncItems();

    int highRisk = screenings.where((s) => s.finalRiskCategory == 'SEVERE' || s.finalRiskCategory == 'MODERATE').length;

    setState(() {
      _totalScreenings = screenings.length;
      _highRiskCount = highRisk;
      _referralsCount = referrals.length;
      _pendingSync = pendingItems.length;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final worker = _authService.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Namaste, ${worker?.fullName ?? "Anita Devi"}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              '${worker?.workerCode ?? "ASHA-UP-VNS-042"} • ${worker?.village ?? "Demo Village"}',
              style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.sync_rounded),
            tooltip: 'Sync Center',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => SyncCenterScreen(syncService: _syncService)),
            ).then((_) => _loadDashboardData()),
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Settings',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            ),
          ),
        ],
      ),
      drawer: _buildAppDrawer(),
      body: RefreshIndicator(
        onRefresh: _loadDashboardData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Obvious Offline Banner
              OfflineIndicator(
                isOnline: _syncService.isOnline,
                pendingCount: _pendingSync,
                onSyncTap: () async {
                  await _syncService.triggerSync();
                  _loadDashboardData();
                },
              ),

              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Primary Action: Start New Screening (Large, prominent)
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppConstants.colorPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 3,
                      ),
                      icon: const Icon(Icons.add_a_photo_rounded, size: 28, color: Colors.white),
                      label: const Text(
                        'Start New Screening',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const StartScreeningScreen()),
                        ).then((_) => _loadDashboardData());
                      },
                    ),

                    const SizedBox(height: 20),

                    // 4 Dashboard KPI Metric Cards (2x2 Grid)
                    Row(
                      children: [
                        Expanded(
                          child: MetricCard(
                            title: 'Total Screenings',
                            value: '$_totalScreenings',
                            icon: Icons.assignment_turned_in_outlined,
                            color: const Color(0xFF0284C7),
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const ScreeningHistoryScreen()),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: MetricCard(
                            title: 'High Risk Triage',
                            value: '$_highRiskCount',
                            icon: Icons.warning_amber_rounded,
                            color: AppConstants.colorSevere,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const ReferralScreen()),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: MetricCard(
                            title: 'Pending Sync',
                            value: '$_pendingSync',
                            icon: Icons.cloud_upload_outlined,
                            color: const Color(0xFFD97706),
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => SyncCenterScreen(syncService: _syncService)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: MetricCard(
                            title: 'Active Referrals',
                            value: '$_referralsCount',
                            icon: Icons.local_hospital_outlined,
                            color: const Color(0xFF8B5CF6),
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const ReferralScreen()),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Secondary Quick-Action Navigation Buttons
                    const Text(
                      'Community Management',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                    ),
                    const SizedBox(height: 12),

                    _buildMenuTile(
                      icon: Icons.person_add_alt_1_rounded,
                      title: 'Register New Patient',
                      subtitle: 'Add beneficiary with pregnancy/demographic details',
                      color: const Color(0xFF059669),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const RegisterPatientScreen()),
                      ).then((_) => _loadDashboardData()),
                    ),
                    const SizedBox(height: 8),

                    _buildMenuTile(
                      icon: Icons.people_alt_outlined,
                      title: 'Patient Directory',
                      subtitle: 'Search registered patients and view history',
                      color: const Color(0xFF0284C7),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const PatientListScreen()),
                      ),
                    ),
                    const SizedBox(height: 8),

                    _buildMenuTile(
                      icon: Icons.history_edu_rounded,
                      title: 'Screening History & Audits',
                      subtitle: 'Review past multi-site image evaluations',
                      color: const Color(0xFF475569),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ScreeningHistoryScreen()),
                      ),
                    ),
                    const SizedBox(height: 8),

                    _buildMenuTile(
                      icon: Icons.science_outlined,
                      title: 'Hackathon Demo Mode',
                      subtitle: 'Synthetic test scenarios and instant reset',
                      color: const Color(0xFFDC2626),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const DemoModeScreen()),
                      ).then((_) => _loadDashboardData()),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
        trailing: const Icon(Icons.chevron_right_rounded, color: Color(0xFF94A3B8)),
        onTap: onTap,
      ),
    );
  }

  Widget _buildAppDrawer() {
    final worker = _authService.currentUser;

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(color: Color(0xFF0F172A)),
            accountName: Text(worker?.fullName ?? 'Anita Devi', style: const TextStyle(fontWeight: FontWeight.bold)),
            accountEmail: Text('${worker?.workerCode} • ${worker?.village}'),
            currentAccountPicture: CircleAvatar(
              backgroundColor: AppConstants.colorPrimary,
              child: const Icon(Icons.person, color: Colors.white, size: 36),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home_outlined),
            title: const Text('Worker Home'),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.people_outline),
            title: const Text('Patients'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (_) => const PatientListScreen()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.history),
            title: const Text('Screenings'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (_) => const ScreeningHistoryScreen()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.local_hospital_outlined),
            title: const Text('Referrals'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (_) => const ReferralScreen()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.sync_rounded),
            title: const Text('Sync Center'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (_) => SyncCenterScreen(syncService: _syncService)));
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.science_outlined, color: AppConstants.colorPrimary),
            title: const Text('Demo Mode & Reset', style: TextStyle(color: AppConstants.colorPrimary, fontWeight: FontWeight.bold)),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (_) => const DemoModeScreen()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.person_outline),
            title: const Text('Profile'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (_) => const WorkerProfileScreen()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Logout', style: TextStyle(color: Colors.red)),
            onTap: () {
              _authService.logout();
              Navigator.pushReplacementNamed(context, '/');
            },
          ),
        ],
      ),
    );
  }
}
