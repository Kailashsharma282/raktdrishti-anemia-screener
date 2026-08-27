import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../core/constants/app_constants.dart';
import '../models/patient_model.dart';
import '../database/db_helper.dart';
import 'start_screening_screen.dart';

class RegisterPatientScreen extends StatefulWidget {
  const RegisterPatientScreen({Key? key}) : super(key: key);

  @override
  State<RegisterPatientScreen> createState() => _RegisterPatientScreenState();
}

class _RegisterPatientScreenState extends State<RegisterPatientScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _phoneController = TextEditingController();
  final _villageController = TextEditingController(text: 'Demo Village');
  final _notesController = TextEditingController();

  String _gender = 'female';
  String _pregnancyStatus = 'pregnant';
  bool _isLoading = false;

  void _savePatient({bool startScreeningImmediately = false}) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final age = int.tryParse(_ageController.text.trim()) ?? 24;
    final now = DateTime.now();
    final patientId = 'p-${const Uuid().v4()}';
    final count = (await LocalDatabase.instance.getPatients()).length + 1;
    final patientCode = 'RD-2026-${count.toString().padLeft(4, '0')}';

    final newPatient = PatientModel(
      id: patientId,
      patientCode: patientCode,
      name: _nameController.text.trim(),
      age: age,
      gender: _gender,
      pregnancyStatus: _gender == 'female' ? _pregnancyStatus : 'not_applicable',
      phone: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
      village: _villageController.text.trim(),
      notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      syncStatus: 'PENDING',
      createdAt: now,
      updatedAt: now,
    );

    await LocalDatabase.instance.insertPatient(newPatient);

    setState(() => _isLoading = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Beneficiary ${newPatient.name} registered (ID: $patientCode)'),
          backgroundColor: const Color(0xFF059669),
        ),
      );

      if (startScreeningImmediately) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => StartScreeningScreen(preSelectedPatient: newPatient),
          ),
        );
      } else {
        Navigator.of(context).pop(newPatient);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register Beneficiary'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Info banner
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, color: Color(0xFF475569), size: 20),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Offline safe: Patient code generated automatically if disconnected.',
                        style: TextStyle(fontSize: 12, color: Color(0xFF334155)),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Full Name
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Patient Full Name *',
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (val) => val == null || val.trim().isEmpty ? 'Please enter patient name' : null,
              ),

              const SizedBox(height: 16),

              // Age & Gender
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: _ageController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Age *',
                        prefixIcon: Icon(Icons.cake_outlined),
                        suffixText: 'yrs',
                      ),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) return 'Required';
                        final num = int.tryParse(val);
                        if (num == null || num < 0 || num > 120) return 'Invalid age';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 3,
                    child: DropdownButtonFormField<String>(
                      value: _gender,
                      decoration: const InputDecoration(labelText: 'Gender *'),
                      items: const [
                        DropdownMenuItem(value: 'female', child: Text('Female')),
                        DropdownMenuItem(value: 'male', child: Text('Male')),
                        DropdownMenuItem(value: 'other', child: Text('Other')),
                      ],
                      onChanged: (val) {
                        setState(() {
                          _gender = val!;
                          if (_gender != 'female') {
                            _pregnancyStatus = 'not_applicable';
                          }
                        });
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Pregnancy Status (Shown if female)
              if (_gender == 'female') ...[
                DropdownButtonFormField<String>(
                  value: _pregnancyStatus,
                  decoration: const InputDecoration(
                    labelText: 'Pregnancy Status *',
                    prefixIcon: Icon(Icons.pregnant_woman_rounded),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'pregnant', child: Text('Pregnant (ANC)')),
                    DropdownMenuItem(value: 'not_pregnant', child: Text('Not Pregnant / Lactating')),
                    DropdownMenuItem(value: 'unknown', child: Text('Unknown / Not Specified')),
                  ],
                  onChanged: (val) => setState(() => _pregnancyStatus = val!),
                ),
                const SizedBox(height: 16),
              ],

              // Village / Locality
              TextFormField(
                controller: _villageController,
                decoration: const InputDecoration(
                  labelText: 'Village / Ward / Locality *',
                  prefixIcon: Icon(Icons.location_on_outlined),
                ),
                validator: (val) => val == null || val.trim().isEmpty ? 'Please enter village' : null,
              ),

              const SizedBox(height: 16),

              // Phone Number (Optional)
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Phone Number (Optional)',
                  prefixIcon: Icon(Icons.phone_outlined),
                  hintText: '+91-9876543210',
                ),
              ),

              const SizedBox(height: 16),

              // Clinical Notes
              TextFormField(
                controller: _notesController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Health Worker Notes (Optional)',
                  prefixIcon: Icon(Icons.note_alt_outlined),
                  hintText: 'e.g., 2nd Trimester, pale conjunctiva noted',
                ),
              ),

              const SizedBox(height: 28),

              // Primary Action: Save & Start Screening Now
              ElevatedButton.icon(
                icon: const Icon(Icons.camera_alt_outlined),
                label: const Text('Save & Start Screening'),
                onPressed: _isLoading ? null : () => _savePatient(startScreeningImmediately: true),
              ),

              const SizedBox(height: 12),

              // Secondary Action: Just Save
              OutlinedButton(
                onPressed: _isLoading ? null : () => _savePatient(startScreeningImmediately: false),
                child: const Text('Save Patient Only'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
