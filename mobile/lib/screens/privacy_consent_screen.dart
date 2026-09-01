import 'package:flutter/material.dart';

class PrivacyConsentScreen extends StatefulWidget {
  final VoidCallback? onConsentGiven;

  const PrivacyConsentScreen({Key? key, this.onConsentGiven}) : super(key: key);

  @override
  State<PrivacyConsentScreen> createState() => _PrivacyConsentScreenState();
}

class _PrivacyConsentScreenState extends State<PrivacyConsentScreen> {
  bool _consentChecked = false;

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
            // Core Explanatory Banner (Section 39)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFBFDBFE)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Purpose of Optical Screening',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1E3A8A)),
                  ),
                  SizedBox(height: 6),
                  Text(
                    '“The app uses camera images to perform anemia-risk screening.”',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1D4ED8),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

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
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    Text(
                      '1. On-Device Processing: Image features (CIELAB color metrics, Erythema indices) are calculated entirely within the local smartphone runtime.\n\n'
                      '2. No Mandatory Cloud Upload of Raw Biometric Images: Images should not be permanently uploaded by default unless explicitly required. Only computed numerical risk scores and anonymized demographic metadata are synchronized.\n\n'
                      '3. Zero Patient Coordinate Tracking: Specific household coordinates are never collected or exposed on public dashboards; only village/district level boundaries are logged for epidemic heatmaps.\n\n'
                      '4. Right to Revoke: Beneficiaries may opt out at any time.',
                      style: TextStyle(fontSize: 13, color: Color(0xFF334155), height: 1.5),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Consent Checkbox
            Card(
              child: CheckboxListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                value: _consentChecked,
                activeColor: const Color(0xFFDC2626),
                title: const Text(
                  'Beneficiary / Legal Guardian has been informed and gave verbal consent for non-invasive camera screening.',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                ),
                onChanged: (val) => setState(() => _consentChecked = val ?? false),
              ),
            ),

            const SizedBox(height: 24),

            // Option to Continue
            ElevatedButton(
              onPressed: _consentChecked
                  ? () {
                      if (widget.onConsentGiven != null) {
                        widget.onConsentGiven!();
                      }
                      Navigator.pop(context, true);
                    }
                  : null,
              child: const Text('Agree & Continue to Camera'),
            ),
          ],
        ),
      ),
    );
  }
}
