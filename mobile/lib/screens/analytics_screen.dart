import 'package:flutter/material.dart';
import '../core/constants/app_constants.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Epidemiological Analytics'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Overall Risk Distribution Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Risk Distribution Overview', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 12),
                    _buildProgressBar('Normal Risk (48%)', 0.48, AppConstants.colorNormal),
                    const SizedBox(height: 8),
                    _buildProgressBar('Mild Risk (22%)', 0.22, AppConstants.colorMild),
                    const SizedBox(height: 8),
                    _buildProgressBar('Moderate Risk (18%)', 0.18, AppConstants.colorModerate),
                    const SizedBox(height: 8),
                    _buildProgressBar('Severe / High Risk (12%)', 0.12, AppConstants.colorSevere),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // 2. Demographic Distribution: Age Groups
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Risk by Age Demographics', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 12),
                    _buildAgeRow('0–5 yrs (Pediatric)', '34% Elevated Risk', 0.34),
                    _buildAgeRow('6–12 yrs (School Age)', '18% Elevated Risk', 0.18),
                    _buildAgeRow('13–18 yrs (Adolescent WIFS)', '28% Elevated Risk', 0.28),
                    _buildAgeRow('19–30 yrs (Reproductive Age)', '42% Elevated Risk', 0.42),
                    _buildAgeRow('31–45 yrs', '22% Elevated Risk', 0.22),
                    _buildAgeRow('46+ yrs (Elderly)', '29% Elevated Risk', 0.29),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // 3. Pregnancy Status Vulnerability Breakdown
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Pregnancy (ANC) Vulnerability', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 8),
                    const Text('Pregnant women exhibit higher prevalence of moderate/severe pallor.', style: TextStyle(color: Color(0xFF64748B), fontSize: 12)),
                    const SizedBox(height: 12),
                    _buildProgressBar('Pregnant (ANC) - 58% Anemia Risk', 0.58, AppConstants.colorSevere),
                    const SizedBox(height: 8),
                    _buildProgressBar('Non-Pregnant Female - 26% Risk', 0.26, AppConstants.colorModerate),
                    const SizedBox(height: 8),
                    _buildProgressBar('Adult Male - 14% Risk', 0.14, AppConstants.colorMild),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar(String label, double fraction, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            Text('${(fraction * 100).toInt()}%', style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 12)),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: fraction,
            backgroundColor: const Color(0xFFE2E8F0),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 8,
          ),
        ),
      ],
    );
  }

  Widget _buildAgeRow(String group, String stat, double fraction) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(group, style: const TextStyle(fontSize: 13, color: Color(0xFF1E293B))),
              Text(stat, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFFDC2626))),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: fraction,
              backgroundColor: const Color(0xFFE2E8F0),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFDC2626)),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }
}
