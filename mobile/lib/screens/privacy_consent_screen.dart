import 'package:flutter/material.dart';

class PrivacyConsentScreen extends StatelessWidget {
  const PrivacyConsentScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy & Clinical Consent'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Row(
                      children: [
                        Icon(Icons.shield_outlined, color: Color(0xFF059669), size: 24),
                        SizedBox(width: 8),
                        Text(
                          'Data Minimization & Local Privacy',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    Text(
                      '1. On-Device Processing: Image features (CIELAB color metrics, Erythema indices) are calculated entirely within the local smartphone runtime.\n\n'
                      '2. No Mandatory Cloud Upload of Raw Biometric Images: Only computed numerical risk scores and anonymized demographic metadata are synchronized to the health ministry database.\n\n'
                      '3. Zero Patient Location Tracking: Specific household coordinates are never collected; only village/district level boundaries are logged for epidemic heatmaps.\n\n'
                      '4. Right to Revoke: Beneficiaries may opt out at any time.',
                      style: TextStyle(fontSize: 13, color: Color(0xFF334155), height: 1.5),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
