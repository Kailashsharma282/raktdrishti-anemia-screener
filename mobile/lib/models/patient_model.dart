class PatientModel {
  final String id;
  final String patientCode;
  final String? workerId;
  final String name;
  final int age;
  final String gender;
  final String pregnancyStatus; // 'pregnant', 'not_pregnant', 'not_applicable', 'unknown'
  final String? phone;
  final String? village;
  final String? notes;
  final String syncStatus; // 'PENDING', 'SYNCING', 'SYNCED', 'FAILED'
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? latestRiskCategory;
  final double? latestRiskScore;
  final int screeningsCount;

  PatientModel({
    required this.id,
    required this.patientCode,
    this.workerId,
    required this.name,
    required this.age,
    required this.gender,
    required this.pregnancyStatus,
    this.phone,
    this.village,
    this.notes,
    this.syncStatus = 'SYNCED',
    required this.createdAt,
    required this.updatedAt,
    this.latestRiskCategory,
    this.latestRiskScore,
    this.screeningsCount = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'patient_code': patientCode,
      'worker_id': workerId,
      'name': name,
      'age': age,
      'gender': gender,
      'pregnancy_status': pregnancyStatus,
      'phone': phone,
      'village': village,
      'notes': notes,
      'sync_status': syncStatus,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory PatientModel.fromMap(Map<String, dynamic> map) {
    return PatientModel(
      id: map['id'],
      patientCode: map['patient_code'] ?? '',
      workerId: map['worker_id'],
      name: map['name'] ?? '',
      age: map['age'] is int ? map['age'] : int.tryParse(map['age'].toString()) ?? 0,
      gender: map['gender'] ?? 'female',
      pregnancyStatus: map['pregnancy_status'] ?? 'not_applicable',
      phone: map['phone'],
      village: map['village'],
      notes: map['notes'],
      syncStatus: map['sync_status'] ?? 'SYNCED',
      createdAt: map['created_at'] != null ? DateTime.parse(map['created_at']) : DateTime.now(),
      updatedAt: map['updated_at'] != null ? DateTime.parse(map['updated_at']) : DateTime.now(),
      latestRiskCategory: map['latest_risk_category'],
      latestRiskScore: map['latest_risk_score'] != null ? (map['latest_risk_score'] as num).toDouble() : null,
      screeningsCount: map['screenings_count'] ?? 0,
    );
  }
}
