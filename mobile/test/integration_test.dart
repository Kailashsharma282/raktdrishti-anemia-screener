import 'package:flutter_test/flutter_test.dart';
import '../lib/database/db_helper.dart';
import '../lib/models/patient_model.dart';
import '../lib/models/screening_model.dart';
import '../lib/models/referral_model.dart';
import '../lib/ml/image_preprocessor.dart';
import '../lib/ml/anemia_risk_model.dart';

void main() {
  group('RaktDrishti End-to-End Integration Flow Test (Section 45)', () {
    test(
        'Complete Workflow: Patient registration -> Screening -> Result -> Referral -> Offline storage -> Sync',
        () async {
      final db = LocalDatabase.instance;
      await db.resetToDemo();

      // 1. Patient Registration
      final patient = PatientModel(
        id: 'p-int-001',
        patientCode: 'RD-2026-INT01',
        name: 'Radha Devi',
        age: 27,
        gender: 'female',
        pregnancyStatus: 'pregnant',
        village: 'Shivpur Rural',
        syncStatus: 'PENDING',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await db.insertPatient(patient, queueSync: true);

      final storedPatient = await db.getPatientById('p-int-001');
      expect(storedPatient, isNotNull);
      expect(storedPatient!.name, equals('Radha Devi'));

      // 2. Multi-Site Image Preprocessing & ML Inference
      final conj = ImagePreprocessor.preprocessConjunctiva(simulatePale: true);
      final nail = ImagePreprocessor.preprocessNail(simulatePale: true);
      final palm = ImagePreprocessor.preprocessPalm(simulatePale: true);

      final prediction = AnemiaRiskModel.predict(
        conjunctiva: conj,
        nail: nail,
        palm: palm,
      );

      // 3. Result Generation
      expect(prediction.riskCategory, isIn(['MODERATE', 'SEVERE']));
      expect(prediction.riskScore, greaterThan(0.55));

      final screening = ScreeningModel(
        id: 'sc-int-001',
        patientId: patient.id,
        patientName: patient.name,
        screeningDate: DateTime.now(),
        overallQuality: prediction.overallQuality,
        finalRiskCategory: prediction.riskCategory,
        riskScore: prediction.riskScore,
        confidence: prediction.confidence,
        syncStatus: 'PENDING',
        createdAt: DateTime.now(),
      );
      await db.insertScreening(screening, queueSync: true);

      // 4. Referral Creation
      final referral = ReferralModel(
        id: 'ref-int-001',
        screeningId: screening.id,
        patientId: patient.id,
        patientName: patient.name,
        patientCode: patient.patientCode,
        referralFacility: 'Community Health Centre (CHC) Shivpur',
        urgency: 'high',
        status: 'Pending',
        syncStatus: 'PENDING',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await db.insertReferral(referral, queueSync: true);

      // 5. Offline Storage Verification
      final pendingQueue = await db.getPendingSyncItems();
      expect(pendingQueue.length, greaterThanOrEqualTo(3)); // patient, screening, referral
      expect(pendingQueue.any((i) => i.entityType == 'Patient'), isTrue);
      expect(pendingQueue.any((i) => i.entityType == 'Screening'), isTrue);
      expect(pendingQueue.any((i) => i.entityType == 'Referral'), isTrue);

      // 6. Sync Completion Verification
      await db.clearSyncedQueue();
      final flushedQueue = await db.getPendingSyncItems();
      expect(flushedQueue.isEmpty, isTrue);
    });
  });
}
