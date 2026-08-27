class ReferralModel {
  final String id;
  final String screeningId;
  final String patientId;
  final String? patientName;
  final String? patientCode;
  final String? workerId;
  final String referralFacility;
  final String urgency; // 'routine', 'high', 'immediate'
  final String status; // 'Pending', 'Referred', 'Lab Test Completed', 'Follow-up Required'
  final double? labConfirmedHb;
  final String? clinicalNotes;
  final String? prescribedTreatment;
  final String syncStatus;
  final DateTime createdAt;
  final DateTime updatedAt;

  ReferralModel({
    required this.id,
    required this.screeningId,
    required this.patientId,
    this.patientName,
    this.patientCode,
    this.workerId,
    required this.referralFacility,
    this.urgency = 'high',
    this.status = 'Pending',
    this.labConfirmedHb,
    this.clinicalNotes,
    this.prescribedTreatment,
    this.syncStatus = 'SYNCED',
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'screening_id': screeningId,
      'patient_id': patientId,
      'worker_id': workerId,
      'referral_facility': referralFacility,
      'urgency': urgency,
      'status': status,
      'lab_confirmed_hb': labConfirmedHb,
      'clinical_notes': clinicalNotes,
      'prescribed_treatment': prescribedTreatment,
      'sync_status': syncStatus,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory ReferralModel.fromMap(Map<String, dynamic> map) {
    return ReferralModel(
      id: map['id'],
      screeningId: map['screening_id'],
      patientId: map['patient_id'],
      patientName: map['patient_name'],
      patientCode: map['patient_code'],
      workerId: map['worker_id'],
      referralFacility: map['referral_facility'] ?? 'CHC Hospital',
      urgency: map['urgency'] ?? 'high',
      status: map['status'] ?? 'Pending',
      labConfirmedHb: (map['lab_confirmed_hb'] as num?)?.toDouble(),
      clinicalNotes: map['clinical_notes'],
      prescribedTreatment: map['prescribed_treatment'],
      syncStatus: map['sync_status'] ?? 'SYNCED',
      createdAt: map['created_at'] != null ? DateTime.parse(map['created_at']) : DateTime.now(),
      updatedAt: map['updated_at'] != null ? DateTime.parse(map['updated_at']) : DateTime.now(),
    );
  }
}
