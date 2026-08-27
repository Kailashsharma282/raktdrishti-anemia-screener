import 'package:flutter/material.dart';
import '../database/db_helper.dart';
import '../models/patient_model.dart';
import '../models/screening_model.dart';
import '../widgets/risk_badge.dart';
import 'screening_result_screen.dart';

class DemoModeScreen extends StatefulWidget {
  const DemoModeScreen({Key? key}) : super(key: key);

  @override
  State<DemoModeScreen> createState() => _DemoModeScreenState();
}

class _DemoModeScreenState extends State<DemoModeScreen> {
  bool _isResetting = false;

  void _resetDemoData() async {
    setState(() => _isResetting = true);
    await LocalDatabase.instance.resetToDemo();
    setState(() => _isResetting = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Demo dataset successfully restored to initial benchmark state!'),
          backgroundColor: Color(0xFF059669),
        ),
      );
    }
  }

  void _launchQuickDemoCase(String patientName, String riskCat, double riskScore) async {
    final now = DateTime.now();
    final p = PatientModel(
      id: 'p-demo-$patientName',
      patientCode: 'RD-DEMO-001',
      name: patientName,
      age: 24,
      gender: 'female',
      pregnancyStatus: 'pregnant',
      village: 'Demo Village',
      syncStatus: 'SYNCED',
      createdAt: now,
      updatedAt: now,
    );

    final sc = ScreeningModel(
      id: 'sc-demo-$patientName',
      patientId: p.id,
      patientName: p.name,
      screeningDate: now,
      overallQuality: 90.0,
      finalRiskCategory: riskCat,
      riskScore: riskScore,
      confidence: 0.88,
      status: 'completed',
      syncStatus: 'SYNCED',
      createdAt: now,
    );

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ScreeningResultScreen(patient: p, screening: sc)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hackathon Demo Bench'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Prominent Demo Mode Badge
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF3C7),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFF59E0B)),
              ),
              child: Column(
                children: const [
                  Text(
                    '⚡ LIVE HACKATHON DEMO BENCH',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Color(0xFFB45309),
                      letterSpacing: 0.8,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Allows judges to test any clinical scenario deterministically without hardware or lighting constraints.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: Color(0xFF78350F)),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              'Simulate One-Click Clinical Cases:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 10),

            _buildCaseButton(
              title: 'Case 1: Ananya Rao (24y, Pregnant)',
              subtitle: 'Moderate Risk Anemia • Score: 72% • Auto-Referral',
              riskCategory: 'MODERATE',
              onTap: () => _launchQuickDemoCase('Ananya Rao', 'MODERATE', 0.72),
            ),
            const SizedBox(height: 10),

            _buildCaseButton(
              title: 'Case 2: Sunita Devi (29y, Postnatal)',
              subtitle: 'Severe Risk Anemia • Score: 86% • Urgent Hospital Triage',
              riskCategory: 'SEVERE',
              onTap: () => _launchQuickDemoCase('Sunita Devi', 'SEVERE', 0.86),
            ),
            const SizedBox(height: 10),

            _buildCaseButton(
              title: 'Case 3: Aarav Kumar (4y, Pediatric)',
              subtitle: 'Normal Risk Profile • Score: 22% • Growth Routine',
              riskCategory: 'NORMAL',
              onTap: () => _launchQuickDemoCase('Aarav Kumar', 'NORMAL', 0.22),
            ),

            const SizedBox(height: 28),

            // Demo Data Reset (Section 58)
            const Text(
              'Demo State Reset:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 6),
            const Text(
              'Clears any test records created during judging and restores baseline demo cohort.',
              style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
            ),
            const SizedBox(height: 12),

            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF475569)),
              icon: _isResetting
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Icon(Icons.restore_page_rounded),
              label: const Text('Reset Demo Data to Initial State'),
              onPressed: _isResetting ? null : _resetDemoData,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCaseButton({
    required String title,
    required String subtitle,
    required String riskCategory,
    required VoidCallback onTap,
  }) {
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.all(14),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14))),
            RiskBadge(riskCategory: riskCategory, fontSize: 10),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Text(subtitle, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
        ),
        trailing: const Icon(Icons.play_circle_fill_rounded, color: Color(0xFFDC2626), size: 28),
        onTap: onTap,
      ),
    );
  }
}
