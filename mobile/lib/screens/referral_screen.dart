import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../models/screening_model.dart';
import '../models/referral_model.dart';
import '../database/db_helper.dart';
import '../widgets/risk_badge.dart';

class ReferralScreen extends StatefulWidget {
  final ScreeningModel? preSelectedScreening;

  const ReferralScreen({Key? key, this.preSelectedScreening}) : super(key: key);

  @override
  State<ReferralScreen> createState() => _ReferralScreenState();
}

class _ReferralScreenState extends State<ReferralScreen> {
  List<ReferralModel> _referrals = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadReferrals();
  }

  Future<void> _loadReferrals() async {
    setState(() => _isLoading = true);
    
    // If incoming new screening referral creation
    if (widget.preSelectedScreening != null) {
      final sc = widget.preSelectedScreening!;
      final existing = (await LocalDatabase.instance.getReferrals())
          .where((r) => r.screeningId == sc.id)
          .toList();

      if (existing.isEmpty) {
        final newRef = ReferralModel(
          id: 'ref-${const Uuid().v4()}',
          screeningId: sc.id,
          patientId: sc.patientId,
          patientName: sc.patientName ?? 'Beneficiary',
          patientCode: 'RD-2026-REF',
          workerId: sc.workerId ?? 'w-asha-001-varanasi',
          referralFacility: sc.finalRiskCategory == 'SEVERE'
              ? 'District Hospital Varanasi'
              : 'Community Health Centre (CHC) Shivpur',
          urgency: sc.finalRiskCategory == 'SEVERE' ? 'immediate' : 'high',
          status: 'Pending',
          clinicalNotes: 'Automated referral generated for ${sc.finalRiskCategory} risk screening.',
          syncStatus: 'PENDING',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        await LocalDatabase.instance.insertReferral(newRef);
      }
    }

    final list = await LocalDatabase.instance.getReferrals();
    setState(() {
      _referrals = list;
      _isLoading = false;
    });
  }

  void _showStatusDialog(ReferralModel ref) {
    String selectedStatus = ref.status;
    final hbController = TextEditingController(
      text: ref.labConfirmedHb != null ? ref.labConfirmedHb.toString() : '',
    );
    final notesController = TextEditingController(text: ref.clinicalNotes ?? '');

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Update Referral Status'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Beneficiary: ${ref.patientName ?? "Patient"}', style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: selectedStatus,
                  decoration: const InputDecoration(labelText: 'Referral Status'),
                  items: const [
                    DropdownMenuItem(value: 'Pending', child: Text('Pending Slip')),
                    DropdownMenuItem(value: 'Referred', child: Text('Referred to CHC/PHC')),
                    DropdownMenuItem(value: 'Lab Test Completed', child: Text('Lab Test Completed')),
                    DropdownMenuItem(value: 'Follow-up Required', child: Text('Follow-up Required')),
                  ],
                  onChanged: (val) => setDialogState(() => selectedStatus = val!),
                ),
                if (selectedStatus == 'Lab Test Completed') ...[
                  const SizedBox(height: 12),
                  TextField(
                    controller: hbController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Confirmed Lab Hb (g/dL)',
                      suffixText: 'g/dL',
                      hintText: 'e.g. 8.5',
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                TextField(
                  controller: notesController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Clinical Notes / Treatment Prescribed',
                    hintText: 'e.g. Prescribed IFA tablets 100mg',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final double? confirmedHb = double.tryParse(hbController.text.trim());
                await LocalDatabase.instance.insertReferral(
                  ReferralModel(
                    id: ref.id,
                    screeningId: ref.screeningId,
                    patientId: ref.patientId,
                    patientName: ref.patientName,
                    patientCode: ref.patientCode,
                    workerId: ref.workerId,
                    referralFacility: ref.referralFacility,
                    urgency: ref.urgency,
                    status: selectedStatus,
                    labConfirmedHb: confirmedHb,
                    clinicalNotes: notesController.text.trim(),
                    prescribedTreatment: ref.prescribedTreatment,
                    syncStatus: 'PENDING',
                    createdAt: ref.createdAt,
                    updatedAt: DateTime.now(),
                  ),
                );
                Navigator.pop(ctx);
                _loadReferrals();
              },
              child: const Text('Update'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Referrals & Triage'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _referrals.isEmpty
              ? const Center(
                  child: Text('No active laboratory referrals found.', style: TextStyle(color: Color(0xFF64748B))),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _referrals.length,
                  itemBuilder: (context, idx) {
                    final r = _referrals[idx];
                    final dateStr = DateFormat('dd MMM yyyy').format(r.createdAt);

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  r.patientName ?? 'Beneficiary',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: _getStatusColor(r.status).withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: _getStatusColor(r.status)),
                                  ),
                                  child: Text(
                                    r.status,
                                    style: TextStyle(
                                      color: _getStatusColor(r.status),
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Referred to: ${r.referralFacility}',
                              style: const TextStyle(fontSize: 13, color: Color(0xFF334155), fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Date: $dateStr  |  Urgency: ${r.urgency.toUpperCase()}',
                              style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                            ),
                            if (r.labConfirmedHb != null) ...[
                              const SizedBox(height: 6),
                              Text(
                                '🔬 Lab Confirmed Hb: ${r.labConfirmedHb} g/dL',
                                style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF059669), fontSize: 13),
                              ),
                            ],
                            if (r.clinicalNotes != null && r.clinicalNotes!.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text('Notes: ${r.clinicalNotes}', style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic)),
                            ],
                            const Divider(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton.icon(
                                  icon: const Icon(Icons.edit_note, size: 18),
                                  label: const Text('Update Status'),
                                  onPressed: () => _showStatusDialog(r),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Lab Test Completed':
        return const Color(0xFF059669);
      case 'Referred':
        return const Color(0xFF0284C7);
      case 'Follow-up Required':
        return const Color(0xFFDC2626);
      default:
        return const Color(0xFFD97706);
    }
  }
}
