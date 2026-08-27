import 'package:flutter/material.dart';
import '../models/patient_model.dart';
import '../models/screening_model.dart';
import '../database/db_helper.dart';
import '../widgets/risk_badge.dart';

class PatientDashboardScreen extends StatefulWidget {
  const PatientDashboardScreen({Key? key}) : super(key: key);

  @override
  State<PatientDashboardScreen> createState() => _PatientDashboardScreenState();
}

class _PatientDashboardScreenState extends State<PatientDashboardScreen> {
  List<PatientModel> _pregnantHighRisk = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadVulnerableCases();
  }

  Future<void> _loadVulnerableCases() async {
    final patients = await LocalDatabase.instance.getPatients();
    setState(() {
      _pregnantHighRisk = patients.where((p) => p.pregnancyStatus == 'pregnant').toList();
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Maternal & High-Risk Priority'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _pregnantHighRisk.isEmpty
              ? const Center(child: Text('No maternal priority cases found.'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _pregnantHighRisk.length,
                  itemBuilder: (context, idx) {
                    final p = _pregnantHighRisk[idx];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: Color(0xFFFEE2E2),
                          child: Icon(Icons.pregnant_woman_rounded, color: Color(0xFFDC2626)),
                        ),
                        title: Text(p.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('${p.patientCode} • ${p.age}y • Village: ${p.village ?? "N/A"}'),
                        trailing: p.latestRiskCategory != null
                            ? RiskBadge(riskCategory: p.latestRiskCategory!, fontSize: 11)
                            : null,
                      ),
                    );
                  },
                ),
    );
  }
}
