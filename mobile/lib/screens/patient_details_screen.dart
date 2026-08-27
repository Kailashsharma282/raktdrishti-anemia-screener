import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/patient_model.dart';
import '../models/screening_model.dart';
import '../database/db_helper.dart';
import '../widgets/risk_badge.dart';
import 'start_screening_screen.dart';
import 'screening_result_screen.dart';

class PatientDetailsScreen extends StatefulWidget {
  final PatientModel patient;

  const PatientDetailsScreen({Key? key, required this.patient}) : super(key: key);

  @override
  State<PatientDetailsScreen> createState() => _PatientDetailsScreenState();
}

class _PatientDetailsScreenState extends State<PatientDetailsScreen> {
  List<ScreeningModel> _screenings = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPatientHistory();
  }

  Future<void> _loadPatientHistory() async {
    setState(() => _isLoading = true);
    final history = await LocalDatabase.instance.getScreenings(patientId: widget.patient.id);
    setState(() {
      _screenings = history;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.patient;

    return Scaffold(
      appBar: AppBar(
        title: Text(p.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_a_photo_rounded, color: Color(0xFFDC2626)),
            tooltip: 'New Screening',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => StartScreeningScreen(preSelectedPatient: p)),
            ).then((_) => _loadPatientHistory()),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Patient Demographic Header Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          p.patientCode,
                          style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFDC2626), fontSize: 14),
                        ),
                        if (p.latestRiskCategory != null)
                          RiskBadge(riskCategory: p.latestRiskCategory!)
                        else
                          const Text('Not Screened', style: TextStyle(color: Color(0xFF64748B), fontSize: 12)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      p.name,
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${p.age} years • ${p.gender.toUpperCase()} • ${p.pregnancyStatus.replaceAll("_", " ").toUpperCase()}',
                      style: const TextStyle(color: Color(0xFF475569), fontSize: 14),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Village: ${p.village ?? "Demo Village"}  |  Phone: ${p.phone ?? "N/A"}',
                      style: const TextStyle(color: Color(0xFF64748B), fontSize: 13),
                    ),
                    if (p.notes != null && p.notes!.isNotEmpty) ...[
                      const Divider(height: 20),
                      Text(
                        'Notes: ${p.notes}',
                        style: const TextStyle(fontStyle: FontStyle.italic, color: Color(0xFF334155), fontSize: 13),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Screening History Timeline Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Screening History & Risk Trends',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                ),
                Text(
                  '${_screenings.length} Record(s)',
                  style: const TextStyle(color: Color(0xFF64748B), fontSize: 13),
                ),
              ],
            ),

            const SizedBox(height: 12),

            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (_screenings.isEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      const Icon(Icons.history_outlined, size: 48, color: Color(0xFF94A3B8)),
                      const SizedBox(height: 12),
                      const Text('No screening records for this patient yet.'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => StartScreeningScreen(preSelectedPatient: p)),
                        ).then((_) => _loadPatientHistory()),
                        child: const Text('Perform First Screening'),
                      ),
                    ],
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _screenings.length,
                itemBuilder: (context, idx) {
                  final sc = _screenings[idx];
                  final dateStr = DateFormat('dd MMM yyyy, hh:mm a').format(sc.screeningDate);

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      leading: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.remove_red_eye_outlined, color: Color(0xFF0F172A)),
                      ),
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(dateStr, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                          RiskBadge(riskCategory: sc.finalRiskCategory, fontSize: 11),
                        ],
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Risk Score: ${(sc.riskScore * 100).toStringAsFixed(0)}%  |  Confidence: ${(sc.confidence * 100).toStringAsFixed(0)}%',
                              style: const TextStyle(fontSize: 13, color: Color(0xFF475569)),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Image Quality: ${sc.overallQuality}% (Conjunctiva, Nails, Palm)',
                              style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                            ),
                            if (sc.referralStatus != null) ...[
                              const SizedBox(height: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEFF6FF),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: const Color(0xFFBFDBFE)),
                                ),
                                child: Text(
                                  'Referral: ${sc.referralStatus}',
                                  style: const TextStyle(color: Color(0xFF1E40AF), fontSize: 11, fontWeight: FontWeight.w600),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ScreeningResultScreen(
                            patient: p,
                            screening: sc,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
