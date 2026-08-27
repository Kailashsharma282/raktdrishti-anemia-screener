import 'package:flutter/material.dart';
import '../models/patient_model.dart';
import '../database/db_helper.dart';
import '../widgets/risk_badge.dart';
import 'patient_details_screen.dart';
import 'register_patient_screen.dart';
import 'start_screening_screen.dart';

class PatientListScreen extends StatefulWidget {
  const PatientListScreen({Key? key}) : super(key: key);

  @override
  State<PatientListScreen> createState() => _PatientListScreenState();
}

class _PatientListScreenState extends State<PatientListScreen> {
  final _searchController = TextEditingController();
  List<PatientModel> _patients = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchPatients();
  }

  Future<void> _fetchPatients({String? query}) async {
    setState(() => _isLoading = true);
    final list = await LocalDatabase.instance.getPatients(search: query);
    setState(() {
      _patients = list;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Beneficiaries & Patients'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_alt_1),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const RegisterPatientScreen()),
            ).then((_) => _fetchPatients()),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Box
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by name, ID, phone...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _fetchPatients();
                        },
                      )
                    : null,
              ),
              onChanged: (val) => _fetchPatients(query: val),
            ),
          ),

          // Patients List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _patients.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.people_outline, size: 64, color: Color(0xFF94A3B8)),
                            const SizedBox(height: 12),
                            const Text('No beneficiaries found', style: TextStyle(fontSize: 16, color: Color(0xFF64748B))),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const RegisterPatientScreen()),
                              ).then((_) => _fetchPatients()),
                              child: const Text('Register New Patient'),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _patients.length,
                        itemBuilder: (context, idx) {
                          final p = _patients[idx];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(12),
                              leading: CircleAvatar(
                                backgroundColor: const Color(0xFFE2E8F0),
                                child: Text(
                                  p.name.isNotEmpty ? p.name[0].toUpperCase() : 'P',
                                  style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                                ),
                              ),
                              title: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      p.name,
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                    ),
                                  ),
                                  if (p.latestRiskCategory != null)
                                    RiskBadge(riskCategory: p.latestRiskCategory!, fontSize: 11),
                                ],
                              ),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(top: 6.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${p.patientCode} • ${p.age}y • ${p.gender.toUpperCase()} ${p.pregnancyStatus == "pregnant" ? "(Pregnant)" : ""}',
                                      style: const TextStyle(color: Color(0xFF475569), fontSize: 13),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${p.village ?? "Demo Village"} • ${p.screeningsCount} screening(s)',
                                      style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.add_a_photo_outlined, color: Color(0xFFDC2626)),
                                tooltip: 'Screen this patient',
                                onPressed: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => StartScreeningScreen(preSelectedPatient: p),
                                  ),
                                ).then((_) => _fetchPatients()),
                              ),
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => PatientDetailsScreen(patient: p),
                                ),
                              ).then((_) => _fetchPatients()),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
