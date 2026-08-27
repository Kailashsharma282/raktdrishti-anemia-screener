import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/patient_model.dart';
import '../models/screening_model.dart';
import '../ml/image_preprocessor.dart';
import '../ml/anemia_risk_model.dart';
import '../database/db_helper.dart';
import 'screening_result_screen.dart';

class ProcessingScreen extends StatefulWidget {
  final PatientModel patient;
  final PreprocessedFeatures conjunctivaFeatures;
  final PreprocessedFeatures nailFeatures;
  final PreprocessedFeatures palmFeatures;

  const ProcessingScreen({
    Key? key,
    required this.patient,
    required this.conjunctivaFeatures,
    required this.nailFeatures,
    required this.palmFeatures,
  }) : super(key: key);

  @override
  State<ProcessingScreen> createState() => _ProcessingScreenState();
}

class _ProcessingScreenState extends State<ProcessingScreen> {
  int _step = 0;
  final List<String> _stages = [
    'Analyzing images…',
    'Checking image quality & lighting…',
    'Normalizing color with calibration card…',
    'Running multi-site optical fusion ML…',
    'Generating screening result…',
  ];

  @override
  void initState() {
    super.initState();
    _runPipeline();
  }

  void _runPipeline() async {
    for (int i = 0; i < _stages.length; i++) {
      if (!mounted) return;
      setState(() => _step = i);
      await Future.delayed(const Duration(milliseconds: 400));
    }

    // Run ML Model
    final prediction = AnemiaRiskModel.predict(
      conjunctiva: widget.conjunctivaFeatures,
      nail: widget.nailFeatures,
      palm: widget.palmFeatures,
    );

    final screeningId = 'sc-${const Uuid().v4()}';
    final now = DateTime.now();

    final screening = ScreeningModel(
      id: screeningId,
      patientId: widget.patient.id,
      patientName: widget.patient.name,
      workerId: widget.patient.workerId ?? 'w-asha-001-varanasi',
      screeningDate: now,
      deviceId: 'Android-Smartphone',
      conjunctivaQuality: widget.conjunctivaFeatures.qualityScore,
      nailQuality: widget.nailFeatures.qualityScore,
      palmQuality: widget.palmFeatures.qualityScore,
      overallQuality: prediction.overallQuality,
      finalRiskCategory: prediction.riskCategory,
      riskScore: prediction.riskScore,
      confidence: prediction.confidence,
      modelVersion: prediction.modelVersion,
      status: 'completed',
      syncStatus: 'PENDING',
      createdAt: now,
    );

    // Save to local offline database
    await LocalDatabase.instance.insertScreening(screening);

    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => ScreeningResultScreen(
            patient: widget.patient,
            screening: screening,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 100,
                height: 100,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFDC2626).withOpacity(0.15),
                  border: Border.all(color: const Color(0xFFDC2626), width: 2),
                ),
                child: const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFDC2626)),
                  strokeWidth: 4,
                ),
              ),
              const SizedBox(height: 32),
              Text(
                _stages[_step],
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'On-Device TFLite Inference (Zero Internet Required)',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF94A3B8),
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 32),
              // Step Progress Dots
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_stages.length, (idx) {
                  return Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: idx <= _step ? const Color(0xFFDC2626) : const Color(0xFF334155),
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
