import 'package:flutter/material.dart';
import '../models/patient_model.dart';
import 'conjunctiva_camera_screen.dart';

class CalibrationInstructionsScreen extends StatelessWidget {
  final PatientModel patient;

  const CalibrationInstructionsScreen({Key? key, required this.patient}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calibration Setup (Step 2/6)'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Step Header
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF2F2),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFFECACA)),
              ),
              child: const Text(
                'Step 2 of 6: Color Calibration Reference Card',
                style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF991B1B), fontSize: 13),
              ),
            ),

            const SizedBox(height: 20),

            // Card Illustration Preview
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Container(
                      height: 140,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFCBD5E1), width: 1.5),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.water_drop, color: Color(0xFFDC2626), size: 18),
                              SizedBox(width: 6),
                              Text(
                                'RaktDrishti™ Reference Card',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          // 6 Primary/Achromatic Patches
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildPatch(Colors.white, 'W', border: true),
                              _buildPatch(const Color(0xFF777777), '18%'),
                              _buildPatch(const Color(0xFF111111), 'K'),
                              _buildPatch(const Color(0xFFD32F2F), 'R'),
                              _buildPatch(const Color(0xFF388E3C), 'G'),
                              _buildPatch(const Color(0xFF1976D2), 'B'),
                            ],
                          ),
                          const SizedBox(height: 6),
                          // 6 Skin Tone / Vascular Patches
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildPatch(const Color(0xFFFCE5D8), 'I-II'),
                              _buildPatch(const Color(0xFFE2AC89), 'III'),
                              _buildPatch(const Color(0xFFBD8B67), 'IV'),
                              _buildPatch(const Color(0xFF8D5524), 'V'),
                              _buildPatch(const Color(0xFFE57373), 'ERY'),
                              _buildPatch(const Color(0xFFF8BBD0), 'PAL'),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Standard 12-Patch Color Reference Grid',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF475569)),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Placement Instructions
            const Text(
              'How to Position the Card:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF0F172A)),
            ),
            const SizedBox(height: 10),

            _buildInstructionRow('1', 'Place the calibration card directly beside the eye, fingernails, or palm.'),
            _buildInstructionRow('2', 'Ensure all 4 corner target markers (⊕) are visible and unshadowed.'),
            _buildInstructionRow('3', 'Hold phone steady under natural indirect light. Avoid direct flash glare.'),
            _buildInstructionRow('4', 'The camera will auto-detect the card before accepting the capture.'),

            const SizedBox(height: 24),

            // Print card action link
            OutlinedButton.icon(
              icon: const Icon(Icons.picture_as_pdf_outlined),
              label: const Text('Download / Print Calibration Card (PDF)'),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Calibration Card PDF located at: assets/calibration/raktdrishti_calibration_card.pdf'),
                  ),
                );
              },
            ),

            const SizedBox(height: 16),

            // Primary Start Capture Button
            ElevatedButton.icon(
              icon: const Icon(Icons.arrow_forward_rounded),
              label: const Text('Start Camera: Conjunctiva (Step 3)'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ConjunctivaCameraScreen(patient: patient),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPatch(Color color, String label, {bool border = false}) {
    return Container(
      width: 32,
      height: 24,
      margin: const EdgeInsets.symmetric(horizontal: 3),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
        border: border ? Border.all(color: Colors.black26) : null,
      ),
      child: Center(
        child: Text(
          label,
          style: TextStyle(
            fontSize: 8,
            fontWeight: FontWeight.bold,
            color: color.computeLuminance() > 0.5 ? Colors.black : Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildInstructionRow(String num, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 10,
            backgroundColor: const Color(0xFFDC2626),
            child: Text(num, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 13, color: Color(0xFF334155)))),
        ],
      ),
    );
  }
}
