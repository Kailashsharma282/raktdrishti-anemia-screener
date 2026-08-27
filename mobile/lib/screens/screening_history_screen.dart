import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/screening_model.dart';
import '../database/db_helper.dart';
import '../widgets/risk_badge.dart';
import 'screening_result_screen.dart';

class ScreeningHistoryScreen extends StatefulWidget {
  const ScreeningHistoryScreen({Key? key}) : super(key: key);

  @override
  State<ScreeningHistoryScreen> createState() => _ScreeningHistoryScreenState();
}

class _ScreeningHistoryScreenState extends State<ScreeningHistoryScreen> {
  List<ScreeningModel> _screenings = [];
  String _filter = 'ALL';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() => _isLoading = true);
    final all = await LocalDatabase.instance.getScreenings();
    setState(() {
      _screenings = all;
      _isLoading = false;
    });
  }

  List<ScreeningModel> get _filteredScreenings {
    if (_filter == 'ALL') return _screenings;
    return _screenings.where((s) => s.finalRiskCategory == _filter).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Screening History'),
      ),
      body: Column(
        children: [
          // Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                _buildFilterChip('ALL', 'All'),
                _buildFilterChip('SEVERE', 'Severe'),
                _buildFilterChip('MODERATE', 'Moderate'),
                _buildFilterChip('MILD', 'Mild'),
                _buildFilterChip('NORMAL', 'Normal'),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredScreenings.isEmpty
                    ? const Center(child: Text('No matching screenings found.'))
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _filteredScreenings.length,
                        itemBuilder: (context, idx) {
                          final sc = _filteredScreenings[idx];
                          final dateStr = DateFormat('dd MMM yyyy, hh:mm a').format(sc.screeningDate);

                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(14),
                              leading: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF1F5F9),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(Icons.water_drop, color: Color(0xFFDC2626)),
                              ),
                              title: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(sc.patientName ?? 'Beneficiary', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                                  RiskBadge(riskCategory: sc.finalRiskCategory, fontSize: 11),
                                ],
                              ),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(top: 6.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Date: $dateStr', style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Risk Score: ${(sc.riskScore * 100).toStringAsFixed(0)}%  |  Quality: ${sc.overallQuality}%',
                                      style: const TextStyle(fontSize: 13, color: Color(0xFF334155), fontWeight: FontWeight.w500),
                                    ),
                                  ],
                                ),
                              ),
                              trailing: const Icon(Icons.chevron_right, color: Color(0xFF94A3B8)),
                              onTap: () async {
                                final p = await LocalDatabase.instance.getPatientById(sc.patientId);
                                if (p != null && mounted) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => ScreeningResultScreen(patient: p, screening: sc),
                                    ),
                                  );
                                }
                              },
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String key, String label) {
    final selected = _filter == key;
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: FilterChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => setState(() => _filter = key),
        selectedColor: const Color(0xFFDC2626).withOpacity(0.2),
        checkmarkColor: const Color(0xFFDC2626),
      ),
    );
  }
}
