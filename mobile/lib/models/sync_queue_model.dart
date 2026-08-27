class SyncQueueItem {
  final String id;
  final String entityType; // 'Patient', 'Screening', 'Referral'
  final String entityId;
  final String action; // 'CREATE', 'UPDATE', 'DELETE'
  final Map<String, dynamic> payload;
  final int retryCount;
  final String status; // 'PENDING', 'SYNCING', 'FAILED'
  final DateTime createdAt;

  SyncQueueItem({
    required this.id,
    required this.entityType,
    required this.entityId,
    required this.action,
    required this.payload,
    this.retryCount = 0,
    this.status = 'PENDING',
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'entity_type': entityType,
      'entity_id': entityId,
      'action': action,
      'payload': payload.toString(),
      'retry_count': retryCount,
      'status': status,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

class ImageCaptureRecord {
  final String siteType; // 'conjunctiva', 'nail', 'palm'
  final String? localPath;
  final double qualityScore;
  final bool calibrationDetected;
  final double illuminationGain;
  final Map<String, dynamic>? colorFeatures;

  ImageCaptureRecord({
    required this.siteType,
    this.localPath,
    this.qualityScore = 85.0,
    this.calibrationDetected = true,
    this.illuminationGain = 1.0,
    this.colorFeatures,
  });

  Map<String, dynamic> toMap() {
    return {
      'site_type': siteType,
      'local_path': localPath,
      'quality_score': qualityScore,
      'calibration_detected': calibrationDetected,
      'illumination_gain': illuminationGain,
      'color_features': colorFeatures,
    };
  }
}
