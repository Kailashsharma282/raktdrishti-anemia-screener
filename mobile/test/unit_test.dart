import 'package:flutter_test/flutter_test.dart';
import '../lib/ml/image_preprocessor.dart';
import '../lib/ml/anemia_risk_model.dart';
import '../lib/database/db_helper.dart';
import '../lib/models/patient_model.dart';

void main() {
  group('RaktDrishti Mobile Logic Unit Tests', () {
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
    });

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
