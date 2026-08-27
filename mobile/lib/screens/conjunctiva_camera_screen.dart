import 'package:flutter/material.dart';
import '../models/patient_model.dart';
import '../widgets/framing_guide_overlay.dart';
import '../widgets/step_progress_bar.dart';
import '../ml/image_preprocessor.dart';
import 'nail_camera_screen.dart';

class ConjunctivaCameraScreen extends StatefulWidget {
  final PatientModel patient;

  const ConjunctivaCameraScreen({Key? key, required this.patient}) : super(key: key);

  @override
  State<ConjunctivaCameraScreen> createState() => _ConjunctivaCameraScreenState();
}

class _ConjunctivaCameraScreenState extends State<ConjunctivaCameraScreen> {
  bool _cardDetected = true;
  bool _isProcessing = false;

  void _onCapture() async {
    setState(() => _isProcessing = true);
    await Future.delayed(const Duration(milliseconds: 500));

    // Preprocess conjunctiva image
    final isModerate = widget.patient.name.contains('Ananya') || widget.patient.name.contains('Sunita');
    final conjFeatures = ImagePreprocessor.preprocessConjunctiva(
      sharpness: 89.0,
      brightness: 124.0,
      contrast: 76.0,
      simulatePale: isModerate,
    );

    setState(() => _isProcessing = false);

    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => NailCameraScreen(
            patient: widget.patient,
            conjunctivaFeatures: conjFeatures,
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
        title: const Text('Capture Inner Eyelid (Step 3/6)', style: TextStyle(color: Colors.white, fontSize: 16)),
        actions: [
          IconButton(
            icon: const Icon(Icons.flip_camera_ios_outlined, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          const StepProgressBar(
            currentStep: 3,
            totalSteps: 6,
            title: 'Palpebral Conjunctiva Capture',
          ),
          Expanded(
            child: Stack(
              children: [
                // Simulated Camera Feed Viewfinder
                Container(
                  color: const Color(0xFF1E293B),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.remove_red_eye_outlined, size: 80, color: Colors.white.withOpacity(0.2)),
                        const SizedBox(height: 12),
                        Text(
                          'Align Lower Eyelid & Card in Box',
                          style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ),

                // Framing Overlay with Card Zone
                FramingGuideOverlay(
                  title: 'Capture Inner Eyelid',
                  anatomicalZone: '👁️ LOWER EYELID',
                  instruction: '1. Patient looks upward. Gently pull down lower eyelid.\n2. Keep calibration card visible in corner.',
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
