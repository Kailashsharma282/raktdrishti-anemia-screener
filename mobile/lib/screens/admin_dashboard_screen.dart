import 'package:flutter/material.dart';
import '../core/constants/app_constants.dart';
import '../widgets/metric_card.dart';
import 'analytics_screen.dart';
import 'patient_list_screen.dart';
import 'screening_history_screen.dart';
import 'referral_screen.dart';
import 'login_screen.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('District Medical Officer Portal'),
        actions: [
          IconButton(
            icon: const Icon(Icons.analytics_outlined),
            tooltip: 'Deep Analytics',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AnalyticsScreen()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const LoginScreen()),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Admin Welcome Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Varanasi District Health Authority',
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Epidemiological Monitoring & Frontline ASHA Network',
                    style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Metrics Grid
            const Row(
              children: [
                Expanded(
                  child: MetricCard(
                    title: 'Total Screened',
                    value: '1,420',
                    icon: Icons.people_alt_outlined,
                    color: Color(0xFF0284C7),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: MetricCard(
                    title: 'Severe Anemia',
                    value: '184',
                    icon: Icons.warning_amber_rounded,
                    color: AppConstants.colorSevere,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Row(
              children: [
                Expanded(
                  child: MetricCard(
                    title: 'Active Frontline Workers',
                    value: '48',
                    icon: Icons.health_and_safety_outlined,
                    color: Color(0xFF059669),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: MetricCard(
                    title: 'Confirmed Referrals',
                    value: '92%',
                    icon: Icons.local_hospital_outlined,
                    color: Color(0xFF8B5CF6),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Location-based summary (Section 34 of PDF)
            const Text(
              'Village / Block Risk Aggregates',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
            ),
            const SizedBox(height: 10),

            _buildVillageCard('Demo Village', 124, 19, 45, 60),
            const SizedBox(height: 8),
            _buildVillageCard('Shivpur Rural', 98, 11, 32, 55),
            const SizedBox(height: 8),
            _buildVillageCard('Ramnagar Block B', 142, 24, 52, 66),

            const SizedBox(height: 24),

            ElevatedButton.icon(
              icon: const Icon(Icons.bar_chart_rounded),
              label: const Text('View Full Analytics & Risk Charts'),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AnalyticsScreen()),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVillageCard(String village, int total, int severe, int moderate, int normal) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(village, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                Text('$total Screenings', style: const TextStyle(color: Color(0xFF64748B), fontSize: 13)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildRiskChip('Severe: $severe', AppConstants.colorSevere),
                const SizedBox(width: 8),
                _buildRiskChip('Moderate: $moderate', AppConstants.colorModerate),
                const SizedBox(width: 8),
                _buildRiskChip('Normal: $normal', AppConstants.colorNormal),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRiskChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold),
      ),
    );
  }
}
