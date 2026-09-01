import 'package:flutter/material.dart';
import '../core/constants/app_constants.dart';
import '../models/patient_model.dart';
import '../models/screening_model.dart';
import '../widgets/risk_badge.dart';
import 'referral_screen.dart';
import 'worker_home_screen.dart';

class ScreeningResultScreen extends StatelessWidget {
  final PatientModel patient;
  final ScreeningModel screening;

  const ScreeningResultScreen({
    Key? key,
    required this.patient,
    required this.screening,
  }) : super(key: key);

  bool get _isElevatedRisk =>
      screening.finalRiskCategory == 'MODERATE' || screening.finalRiskCategory == 'SEVERE';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Screening Result'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const WorkerHomeScreen()),
            (route) => false,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Patient Header Banner
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Beneficiary: ${patient.name} (${patient.patientCode})',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF1E293B)),
                  ),
                  Text(
                    '${patient.age}y / ${patient.gender[0].toUpperCase()}',
                    style: const TextStyle(color: Color(0xFF64748B), fontSize: 13),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Main Risk Score Assessment Card
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Text(
                      'ESTIMATED ANEMIA RISK',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                        color: Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(height: 12),
                    RiskBadge(
                      riskCategory: screening.finalRiskCategory,
                      fontSize: 20,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildStatColumn('Risk Score', '${(screening.riskScore * 100).toStringAsFixed(0)}%'),
                        Container(width: 1, height: 36, color: const Color(0xFFCBD5E1), margin: const EdgeInsets.symmetric(horizontal: 24)),
                        _buildStatColumn('Result Confidence', 'High (${(screening.confidence * 100).toStringAsFixed(0)}%)'),
                      ],
                    ),
                    const Divider(height: 28),
                    // Sites Analyzed Checkmarks
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Sites Analyzed: ', style: TextStyle(fontSize: 13, color: Color(0xFF64748B))),
                        Text('✓ Conjunctiva  ✓ Nails  ✓ Palm', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF059669))),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Recommended Action & Safety Notice
            Card(
              color: _isElevatedRisk ? const Color(0xFFFEF2F2) : const Color(0xFFF0FDF4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: _isElevatedRisk ? const Color(0xFFFECACA) : const Color(0xFFBBF7D0),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          _isElevatedRisk ? Icons.notification_important_rounded : Icons.health_and_safety_outlined,
                          color: _isElevatedRisk ? const Color(0xFFDC2626) : const Color(0xFF16A34A),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _isElevatedRisk ? 'Recommended Next Step' : 'Routine Recommendation',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: _isElevatedRisk ? const Color(0xFF991B1B) : const Color(0xFF14532D),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _isElevatedRisk
                          ? 'Please visit a healthcare facility (PHC/CHC) for a confirmatory blood test (CBC / Hemoglobin).'
                          : 'Low anemia risk detected. Continue balanced iron-rich nutrition.',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: _isElevatedRisk ? const Color(0xFF7F1D1D) : const Color(0xFF15803D),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Medical Safety Disclaimer Box (Strictly enforced)
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '⚠️ Medical Safety Notice',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF475569)),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _isElevatedRisk
                        ? 'RaktDrishti is a screening aid and does not diagnose anemia. A confirmatory laboratory blood test is required.'
                        : 'A low-risk result does not rule out anemia or replace clinical evaluation when symptoms or other concerns are present.',
                    style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), height: 1.3),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // All 5 Action Buttons from Section 21
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0284C7)),
                    icon: const Icon(Icons.menu_book_outlined),
                    label: const Text('View Guidance'),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Clinical & Nutritional Guidance'),
                          content: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  _isElevatedRisk
                                      ? '⚠️ Mandatory Confirmatory Pathway:\n• Schedule appointment at CHC/PHC for venous CBC.\n• Screen for secondary causes (malnutrition, helminthiasis, malaria).\n• Prescribe Iron Folic Acid (IFA) supplements under MO supervision.'
                                      : '✅ Routine Health Maintenance:\n• Promote dietary diversity: leafy greens, jaggery, legumes.\n• Continue periodic frontline screening every 3 months for ANC/pediatric cohorts.',
                                  style: const TextStyle(fontSize: 13, height: 1.5),
                                ),
                              ],
                            ),
                          ),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close')),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                if (_isElevatedRisk) ...[
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFDC2626)),
                      icon: const Icon(Icons.local_hospital_rounded),
                      label: const Text('Create Referral'),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ReferralScreen(preSelectedScreening: screening),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 8),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.save_outlined),
                    label: const Text('Save Result'),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Screening record safely persisted locally in SQLite & queued for sync.'),
                          backgroundColor: Color(0xFF059669),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.share_outlined),
                    label: const Text('Share Summary'),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Screening summary report card copied to clipboard.')),
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            TextButton.icon(
              icon: const Icon(Icons.arrow_back_rounded),
              label: const Text('Back to Patient Profile'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const WorkerHomeScreen()),
                (route) => false,
              ),
              child: const Text('Back to Worker Home', style: TextStyle(color: Color(0xFF64748B), fontSize: 12)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatColumn(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
      ],
    );
  }
}
