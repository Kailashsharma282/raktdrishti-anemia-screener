import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../lib/screens/login_screen.dart';
import '../lib/screens/register_patient_screen.dart';
import '../lib/screens/screening_result_screen.dart';
import '../lib/widgets/offline_indicator.dart';
import '../lib/models/patient_model.dart';
import '../lib/models/screening_model.dart';

void main() {
  group('RaktDrishti Flutter Widget Tests (Section 45)', () {
    // 1. Login Screen Widget Test
    testWidgets('LoginScreen renders logo, inputs, and login action', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: LoginScreen()));

      expect(find.text('RaktDrishti'), findsOneWidget);
      expect(find.text('Login to RaktDrishti'), findsOneWidget);
      expect(find.byType(TextField), findsNWidgets(2));
      expect(find.text('Offline Enabled: Works seamlessly without internet'), findsOneWidget);
    });

    // 2. Patient Registration Form Widget Test
    testWidgets('RegisterPatientScreen renders fields and offline-safe banner', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: RegisterPatientScreen()));

      expect(find.text('Register Beneficiary'), findsOneWidget);
      expect(find.text('Patient Full Name *'), findsOneWidget);
      expect(find.text('Save & Start Screening'), findsOneWidget);
      expect(find.text('Offline safe: Patient code generated automatically if disconnected.'), findsOneWidget);
    });

    // 3. Offline Indicator Widget Test
    testWidgets('OfflineIndicator displays correct status banner and sync action', (WidgetTester tester) async {
      // Test Offline Mode
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: OfflineIndicator(
              isOnline: false,
              pendingCount: 3,
              onSyncTap: () {},
            ),
          ),
        ),
      );

      expect(find.text('OFFLINE MODE — 3 records waiting to sync'), findsOneWidget);
      expect(find.text('Data will sync automatically'), findsOneWidget);

      // Test Online Mode
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: OfflineIndicator(
              isOnline: true,
              pendingCount: 0,
              onSyncTap: () {},
            ),
          ),
        ),
      );

      expect(find.text('ONLINE — All records synchronized with cloud'), findsOneWidget);
    });

    // 4. Result Page Widget Test
    testWidgets('ScreeningResultScreen renders risk tier, quality, and guidance buttons', (WidgetTester tester) async {
      final mockPatient = PatientModel(
        id: 'p-test-01',
        patientCode: 'RD-2026-0042',
        name: 'Ananya Rao',
        age: 24,
        gender: 'female',
        pregnancyStatus: 'pregnant',
        village: 'Demo Village',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final mockScreening = ScreeningModel(
        id: 'sc-test-01',
        patientId: mockPatient.id,
        screeningDate: DateTime.now(),
        overallQuality: 92.0,
        finalRiskCategory: 'MODERATE',
        riskScore: 0.72,
        confidence: 0.81,
        createdAt: DateTime.now(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: ScreeningResultScreen(
            patient: mockPatient,
            screening: mockScreening,
          ),
        ),
      );

      expect(find.text('Screening Result'), findsOneWidget);
      expect(find.text('MODERATE RISK'), findsOneWidget);
      expect(find.text('View Guidance'), findsOneWidget);
      expect(find.text('Create Referral'), findsOneWidget);
      expect(find.text('Save Result'), findsOneWidget);
      expect(find.text('Share Summary'), findsOneWidget);
    });
  });
}
