import 'package:flutter/material.dart';
import '../models/patient_model.dart';
import '../database/db_helper.dart';
import 'calibration_instructions_screen.dart';
import 'register_patient_screen.dart';

class StartScreeningScreen extends StatefulWidget {
  final PatientModel? preSelectedPatient;

  const StartScreeningScreen({Key? key, this.preSelectedPatient}) : super(key: key);

  @override
  State<StartScreeningScreen> createState() => _StartScreeningScreenState();
}

class _StartScreeningScreenState extends State<StartScreeningScreen> {
  PatientModel? _selectedPatient;
  List<PatientModel> _allPatients = [];
  bool _consentGiven = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _selectedPatient = widget.preSelectedPatient;
    _loadPatients();
  }

  Future<void> _loadPatients() async {
    final list = await LocalDatabase.instance.getPatients();
    setState(() {
      _allPatients = list;
      if (_selectedPatient == null && list.isNotEmpty) {
        _selectedPatient = list.first;
      }
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Start Screening (Step 1/6)'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Step Indicator
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF2F2),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFFECACA)),
                    ),
                    child: const Text(
                      'Step 1 of 6: Beneficiary Selection & Informed Consent',
                      style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF991B1B), fontSize: 13),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Patient Selector Card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Select Beneficiary', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              TextButton.icon(
                                icon: const Icon(Icons.person_add, size: 18),
                                label: const Text('New'),
                                onPressed: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => const RegisterPatientScreen()),
                                ).then((_) => _loadPatients()),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          if (_allPatients.isEmpty)
                            const Text('No patients registered yet. Click New to add.')
                          else
                            DropdownButtonFormField<String>(
                              value: _selectedPatient?.id,
                              decoration: const InputDecoration(labelText: 'Beneficiary Name'),
                              items: _allPatients.map((p) {
                                return DropdownMenuItem(
                                  value: p.id,
                                  child: Text('${p.name} (${p.patientCode}) - ${p.age}y'),
                                );
                              }).toList(),
                              onChanged: (val) {
                                setState(() {
                                  _selectedPatient = _allPatients.firstWhere((p) => p.id == val);
                                });
                              },
                            ),
                          if (_selectedPatient != null) ...[
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Selected: ${_selectedPatient!.name}',
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${_selectedPatient!.gender.toUpperCase()} • ${_selectedPatient!.age} yrs • Village: ${_selectedPatient!.village ?? "N/A"}',
                                    style: const TextStyle(color: Color(0xFF64748B), fontSize: 13),
                                  ),
                                  if (_selectedPatient!.pregnancyStatus == 'pregnant')
                                    const Padding(
                                      padding: EdgeInsets.only(top: 4),
                                      child: Text(
                                        '⚠️ Pregnant Beneficiary (ANC Protocol Active)',
                                        style: TextStyle(color: Color(0xFFDC2626), fontWeight: FontWeight.w600, fontSize: 12),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Informed Clinical Consent Checkbox
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Patient Consent & Privacy Disclosure',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'The app uses smartphone camera images of the eye, nails, and palm to estimate anemia risk. All images are processed locally on-device. This is an engineering triage tool, NOT a final diagnosis.',
                            style: TextStyle(fontSize: 13, color: Color(0xFF475569), height: 1.4),
                          ),
                          const Divider(height: 20),
                          CheckboxListTile(
                            contentPadding: EdgeInsets.zero,
                            title: const Text(
                              'Patient/Guardian has provided informed verbal consent for non-invasive optical screening.',
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                            ),
                            value: _consentGiven,
                            activeColor: const Color(0xFFDC2626),
                            onChanged: (val) => setState(() => _consentGiven = val ?? false),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Proceed Button
                  ElevatedButton(
                    onPressed: (_selectedPatient != null && _consentGiven)
                        ? () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => CalibrationInstructionsScreen(patient: _selectedPatient!),
                              ),
                            );
                          }
                        : null,
                    child: const Text('Proceed to Calibration Card (Step 2)'),
                  ),
                ],
              ),
            ),
    );
  }
}
