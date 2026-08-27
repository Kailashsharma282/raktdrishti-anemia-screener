import 'package:flutter/material.dart';
import '../core/constants/app_constants.dart';
import 'privacy_consent_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _serverUrlController = TextEditingController(text: 'http://10.0.2.2:8000/api/v1');
  bool _autoSync = true;
  bool _highContrast = false;
  String _selectedLanguage = 'en';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Application Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Localization (Section 63)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Language / भाषा', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: _selectedLanguage,
                    decoration: const InputDecoration(labelText: 'Display Language'),
                    items: const [
                      DropdownMenuItem(value: 'en', child: Text('English (Default)')),
                      DropdownMenuItem(value: 'hi', child: Text('हिन्दी (Hindi - ASHA/ANM Friendly)')),
                    ],
                    onChanged: (val) => setState(() => _selectedLanguage = val!),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Backend API Config
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Backend & Cloud Endpoints', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _serverUrlController,
                    decoration: const InputDecoration(
                      labelText: 'FastAPI Server Base URL',
                      hintText: 'http://10.0.2.2:8000/api/v1',
                      prefixIcon: Icon(Icons.dns_outlined),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Auto-sync upon reconnection', style: TextStyle(fontSize: 14)),
                    value: _autoSync,
                    onChanged: (val) => setState(() => _autoSync = val),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Accessibility & Medical Privacy
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.privacy_tip_outlined),
                  title: const Text('Patient Privacy & Consent Policy'),
                  subtitle: const Text('View biometric data retention rules'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const PrivacyConsentScreen()),
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.info_outline),
                  title: const Text('About RaktDrishti'),
                  subtitle: const Text('Omnikon 2026 BioTech Hackathon MVP'),
                  trailing: Text(AppConstants.appVersion, style: const TextStyle(color: Color(0xFF64748B), fontSize: 12)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
