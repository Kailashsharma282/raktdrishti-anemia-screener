import 'package:flutter/material.dart';
import '../models/patient_model.dart';
import '../widgets/framing_guide_overlay.dart';
import '../widgets/step_progress_bar.dart';
import '../ml/image_preprocessor.dart';
import 'image_quality_screen.dart';

class PalmCameraScreen extends StatefulWidget {
  final PatientModel patient;
  final PreprocessedFeatures conjunctivaFeatures;
  final PreprocessedFeatures nailFeatures;

  const PalmCameraScreen({
    Key? key,
    required this.patient,
    required this.conjunctivaFeatures,
    required this.nailFeatures,
  }) : super(key: key);

  @override
  State<PalmCameraScreen> createState() => _PalmCameraScreenState();
}

class _PalmCameraScreenState extends State<PalmCameraScreen> {
  bool _cardDetected = true;
  bool _isProcessing = false;

  void _onCapture() async {
    setState(() => _isProcessing = true);
    await Future.delayed(const Duration(milliseconds: 500));

    final isModerate = widget.patient.name.contains('Ananya') || widget.patient.name.contains('Sunita');
    final palmFeatures = ImagePreprocessor.preprocessPalm(
      sharpness: 87.0,
      brightness: 126.0,
      contrast: 74.0,
      simulatePale: isModerate,
    );

    setState(() => _isProcessing = false);

    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ImageQualityScreen(
            patient: widget.patient,
            conjunctivaFeatures: widget.conjunctivaFeatures,
            nailFeatures: widget.nailFeatures,
            palmFeatures: palmFeatures,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text('Capture Open Palm (Step 5/6)', style: TextStyle(color: Colors.white, fontSize: 16)),
      ),
      body: Column(
        children: [
          const StepProgressBar(
            currentStep: 5,
            totalSteps: 6,
            title: 'Palmar Crease & Skin Pallor Capture',
          ),
          Expanded(
            child: Stack(
              children: [
                Container(
                  color: const Color(0xFF1E293B),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.front_hand_outlined, size: 80, color: Colors.white.withOpacity(0.2)),
                        const SizedBox(height: 12),
                        Text(
                          'Align Open Palm & Card in Box',
                          style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ),
                FramingGuideOverlay(
                  title: 'Capture Palm',
                  anatomicalZone: '✋ OPEN PALM',
                  instruction: '1. Open palm completely flat. Avoid harsh shadows.\n2. Place calibration card directly beside palm.',
                  isCardVisible: _cardDetected,
                  onCapture: _isProcessing ? () {} : _onCapture,
                ),
                if (_isProcessing)
                  Container(
                    color: Colors.black54,
                    child: const Center(
                      child: CircularProgressIndicator(color: Color(0xFFDC2626)),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
