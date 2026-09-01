import 'package:flutter_test/flutter_test.dart';
import '../lib/ml/image_preprocessor.dart';
import '../lib/ml/calibration_engine.dart';
import '../lib/ml/anemia_risk_model.dart';
import '../lib/database/db_helper.dart';
import '../lib/models/patient_model.dart';

void main() {
  group('RaktDrishti Mobile Logic Unit Tests (Section 45)', () {
    // 1. Image Quality Scoring
    test('Image Quality Assessment score computation', () {
      final quality = ImagePreprocessor.calculateImageQuality(
        sharpness: 88.0,
        brightness: 124.0,
        contrast: 76.0,
        calibrationVisibility: 95.0,
        regionVisibility: 90.0,
      );
      expect(quality, greaterThanOrEqualTo(60.0));
      expect(quality, lessThanOrEqualTo(100.0));
    });

    // 2. Calibration Logic
    test('Calibration Engine patch detection, gain calculation, and CCM normalization', () {
      final isCardVisible = CalibrationEngine.verifyCardVisibility(
        sharpness: 85.0,
        brightness: 120.0,
        simulatedPresence: true,
      );
      expect(isCardVisible, isTrue);

      final gain = CalibrationEngine.computeIlluminationGain(110.0);
      expect(gain, greaterThan(1.0));
      expect(gain, lessThan(1.2));

      final detected = CalibrationEngine.extractDetectedPatches(
        ambientLux: 110.0,
        colorTempK: 5500.0,
      );
      expect(detected.containsKey('white'), isTrue);
      expect(detected.containsKey('gray_18'), isTrue);

      final ccmResult = CalibrationEngine.estimateColorCorrection(detectedPatches: detected);
      expect(ccmResult['isCalibrated'], isTrue);
      expect(ccmResult['qualityDeltaScore'], greaterThan(60.0));

      final corrected = CalibrationEngine.normalizeRgb(
        {'r': 180.0, 'g': 140.0, 'b': 130.0},
        ccmResult['rGain'],
        ccmResult['bGain'],
      );
      expect(corrected['r'], isNotNull);
      expect(corrected['g'], equals(140.0));
    });

    // 3. Risk Categorization
    test('Anemia Risk Model Multi-Site Fusion categorization', () {
      // Normal Case
      final conjNorm = ImagePreprocessor.preprocessConjunctiva(simulatePale: false);
      final nailNorm = ImagePreprocessor.preprocessNail(simulatePale: false);
      final palmNorm = ImagePreprocessor.preprocessPalm(simulatePale: false);

      final normResult = AnemiaRiskModel.predict(
        conjunctiva: conjNorm,
        nail: nailNorm,
        palm: palmNorm,
      );
      expect(normResult.riskCategory, isIn(['NORMAL', 'MILD']));
      expect(normResult.riskScore, lessThan(0.56));
      expect(normResult.inferenceTimestamp, isNotNull);

      // Pale / Anemia Case
      final conjPale = ImagePreprocessor.preprocessConjunctiva(simulatePale: true);
      final nailPale = ImagePreprocessor.preprocessNail(simulatePale: true);
      final palmPale = ImagePreprocessor.preprocessPalm(simulatePale: true);

      final paleResult = AnemiaRiskModel.predict(
        conjunctiva: conjPale,
        nail: nailPale,
        palm: palmPale,
      );
      expect(paleResult.riskCategory, isIn(['MODERATE', 'SEVERE']));
      expect(paleResult.riskScore, greaterThanOrEqualTo(0.56));
      expect(paleResult.isDemoModel, isTrue);
    });

    // 4. Patient Validation
    test('Patient registration model validation rules', () {
      final validPatient = PatientModel(
        id: 'p-val-001',
        patientCode: 'RD-2026-0099',
        name: 'Sunita Devi',
        age: 28,
        gender: 'female',
        pregnancyStatus: 'pregnant',
        village: 'Demo Village',
        phone: '+91-9876543210',
        syncStatus: 'PENDING',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      expect(validPatient.name.isNotEmpty, isTrue);
      expect(validPatient.age, inInclusiveRange(0, 120));
      expect(['pregnant', 'not_pregnant', 'unknown', 'not_applicable'], contains(validPatient.pregnancyStatus));
      expect(validPatient.patientCode.startsWith('RD-'), isTrue);
    });

    // 5. Sync Queue & Offline Local Storage
    test('Offline Local Database CRUD and Sync Queue', () async {
      final db = LocalDatabase.instance;
      await db.resetToDemo();

      final initialPatients = await db.getPatients();
      expect(initialPatients.isNotEmpty, true);

      final newPatient = PatientModel(
        id: 'p-test-offline-1',
        patientCode: 'RD-TEST-001',
        name: 'Meena Sharma',
        age: 26,
        gender: 'female',
        pregnancyStatus: 'pregnant',
        village: 'Demo Village',
        syncStatus: 'PENDING',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await db.insertPatient(newPatient, queueSync: true);

      final pending = await db.getPendingSyncItems();
      expect(pending.any((i) => i.entityId == 'p-test-offline-1'), true);

      await db.clearSyncedQueue();
      final afterClear = await db.getPendingSyncItems();
      expect(afterClear.isEmpty, true);
    });
  });
}
