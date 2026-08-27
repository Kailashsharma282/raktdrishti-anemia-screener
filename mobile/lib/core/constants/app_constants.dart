import 'package:flutter/material.dart';

class AppConstants {
  static const String appName = 'RaktDrishti';
  static const String appTagline = 'See the risk. Confirm with confidence.';
  static const String shortDescription = 'Non-invasive anemia risk screening';
  static const String appVersion = 'v1.0.0-hackathon-mvp';

  // Medical Safety Disclaimer
  static const String medicalDisclaimer =
      'RaktDrishti is a screening aid and does not diagnose anemia. High-risk results require confirmatory laboratory blood testing.';

  // Risk Categories
  static const String riskNormal = 'NORMAL';
  static const String riskMild = 'MILD';
  static const String riskModerate = 'MODERATE';
  static const String riskSevere = 'SEVERE';

  // Risk Colors
  static const Color colorNormal = Color(0xFF10B981); // Emerald Green
  static const Color colorMild = Color(0xFFF59E0B);   // Amber
  static const Color colorModerate = Color(0xFFF97316); // Orange
  static const Color colorSevere = Color(0xFFEF4444); // Crimson Red
  static const Color colorPrimary = Color(0xFFDC2626); // Brand Red
  static const Color colorSecondary = Color(0xFF1E293B); // Slate Dark

  // Sync Statuses
  static const String syncPending = 'PENDING';
  static const String syncSyncing = 'SYNCING';
  static const String syncSynced = 'SYNCED';
  static const String syncFailed = 'FAILED';

  // Thresholds
  static const double qualityThreshold = 60.0;
  static const double calibrationConfidenceMin = 0.70;
}
