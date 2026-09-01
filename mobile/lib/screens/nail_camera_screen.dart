import 'package:flutter/material.dart';
import '../models/patient_model.dart';
import '../widgets/framing_guide_overlay.dart';
import '../widgets/step_progress_bar.dart';
import '../ml/image_preprocessor.dart';
import 'palm_camera_screen.dart';

class NailCameraScreen extends StatefulWidget {
  final PatientModel patient;
  final PreprocessedFeatures conjunctivaFeatures;

  const NailCameraScreen({
    Key? key,
    required this.patient,
    required this.conjunctivaFeatures,
  }) : super(key: key);

  @override
  State<NailCameraScreen> createState() => _NailCameraScreenState();
}

class _NailCameraScreenState extends State<NailCameraScreen> {
  bool _cardDetected = true;
  bool _isProcessing = false;

  void _onCapture() async {
    setState(() => _isProcessing = true);
    await Future.delayed(const Duration(milliseconds: 500));

    final isModerate = widget.patient.name.contains('Ananya') || widget.patient.name.contains('Sunita');
    final nailFeatures = ImagePreprocessor.preprocessNail(
      sharpness: 91.0,
      brightness: 122.0,
      contrast: 79.0,
      simulatePale: isModerate,
    );

    setState(() => _isProcessing = false);

    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PalmCameraScreen(
            patient: widget.patient,
            conjunctivaFeatures: widget.conjunctivaFeatures,
            nailFeatures: nailFeatures,
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
        title: const Text('Capture Fingernails (Step 4/6)', style: TextStyle(color: Colors.white, fontSize: 16)),
      ),
      body: Column(
        children: [
          const StepProgressBar(
            currentStep: 4,
            totalSteps: 6,
            title: 'Nail Bed Capillaries Capture',
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
                        Icon(Icons.pan_tool_alt_outlined, size: 80, color: Colors.white.withOpacity(0.2)),
                        const SizedBox(height: 12),
                        Text(
                          'Align Fingernails & Card in Box',
                          style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ),
                FramingGuideOverlay(
                  title: 'Capture Fingernails',
                  anatomicalZone: '💅 NAIL BEDS',
                  instruction: '• Place fingernails inside guide • Keep calibration card visible\n• Avoid harsh shadows • Keep hand steady • Capture multiple visible nails',
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
