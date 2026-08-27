import 'package:flutter/material.dart';

class FramingGuideOverlay extends StatelessWidget {
  final String title;
  final String instruction;
  final String anatomicalZone;
  final VoidCallback onCapture;
  final bool isCardVisible;

  const FramingGuideOverlay({
    Key? key,
    required this.title,
    required this.instruction,
    required this.anatomicalZone,
    required this.onCapture,
    this.isCardVisible = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Camera Viewfinder Box & Calibration Zone
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Main Anatomical Region Box
              Container(
                width: 280,
                height: 220,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: isCardVisible ? const Color(0xFF10B981) : Colors.white,
                    width: 2.5,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.black.withOpacity(0.1),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      top: 10,
                      left: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          anatomicalZone,
                          style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    // Calibration Card Sub-Guide in top-right
                    Positioned(
                      top: 10,
                      right: 10,
                      child: Container(
                        width: 70,
                        height: 50,
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xFFF59E0B), width: 1.5),
                          borderRadius: BorderRadius.circular(6),
                          color: const Color(0xFFF59E0B).withOpacity(0.2),
                        ),
                        child: const Center(
                          child: Text(
                            'CARD\nZONE',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Instruction Banner
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.75),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  instruction,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white, fontSize: 13, height: 1.3),
                ),
              ),
            ],
          ),
        ),

        // Bottom Capture Controls
        Positioned(
          bottom: 40,
          left: 0,
          right: 0,
          child: Column(
            children: [
              GestureDetector(
                onTap: onCapture,
                child: Container(
                  width: 76,
                  height: 76,
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                  ),
                  child: Container(
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFFDC2626),
                    ),
                    child: const Icon(Icons.camera_alt, color: Colors.white, size: 34),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Hold phone steady ~15 cm away',
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
