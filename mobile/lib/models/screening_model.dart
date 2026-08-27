class ScreeningModel {
  final String id;
  final String patientId;
  final String? patientName;
  final String? workerId;
  final DateTime screeningDate;
  final String? deviceId;

  final double conjunctivaQuality;
  final double nailQuality;
  final double palmQuality;
  final double overallQuality;

  final String finalRiskCategory; // NORMAL, MILD, MODERATE, SEVERE
  final double riskScore; // 0.0 to 1.0
  final double confidence; // 0.0 to 1.0
  final String modelVersion;
  final String status;
  final String syncStatus;
  final String? referralId;
  final String? referralStatus;
  final DateTime createdAt;

  ScreeningModel({
    required this.id,
    required this.patientId,
    this.patientName,
    this.workerId,
    required this.screeningDate,
    this.deviceId,
    this.conjunctivaQuality = 80.0,
    this.nailQuality = 80.0,
    this.palmQuality = 80.0,
    required this.overallQuality,
    required this.finalRiskCategory,
    required this.riskScore,
    required this.confidence,
    this.modelVersion = 'v1.0.0-mvp-demo',
    this.status = 'completed',
    this.syncStatus = 'SYNCED',
    this.referralId,
    this.referralStatus,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'patient_id': patientId,
      'worker_id': workerId,
      'screening_date': screeningDate.toIso8601String(),
      'device_id': deviceId,
      'conjunctiva_quality': conjunctivaQuality,
      'nail_quality': nailQuality,
      'palm_quality': palmQuality,
      'overall_quality': overallQuality,
      'final_risk_category': finalRiskCategory,
      'risk_score': riskScore,
      'confidence': confidence,
      'model_version': modelVersion,
      'status': status,
      'sync_status': syncStatus,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory ScreeningModel.fromMap(Map<String, dynamic> map) {
    return ScreeningModel(
      id: map['id'],
      patientId: map['patient_id'],
      patientName: map['patient_name'],
      workerId: map['worker_id'],
      screeningDate: map['screening_date'] != null ? DateTime.parse(map['screening_date']) : DateTime.now(),
      deviceId: map['device_id'],
      conjunctivaQuality: (map['conjunctiva_quality'] as num?)?.toDouble() ?? 80.0,
      nailQuality: (map['nail_quality'] as num?)?.toDouble() ?? 80.0,
      palmQuality: (map['palm_quality'] as num?)?.toDouble() ?? 80.0,
      overallQuality: (map['overall_quality'] as num?)?.toDouble() ?? 80.0,
      finalRiskCategory: map['final_risk_category'] ?? 'NORMAL',
      riskScore: (map['risk_score'] as num?)?.toDouble() ?? 0.0,
      confidence: (map['confidence'] as num?)?.toDouble() ?? 0.85,
      modelVersion: map['model_version'] ?? 'v1.0.0-mvp-demo',
      status: map['status'] ?? 'completed',
      syncStatus: map['sync_status'] ?? 'SYNCED',
      referralId: map['referral_id'],
      referralStatus: map['referral_status'],
      createdAt: map['created_at'] != null ? DateTime.parse(map['created_at']) : DateTime.now(),
    );
  }
}
