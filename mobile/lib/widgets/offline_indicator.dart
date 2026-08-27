import 'package:flutter/material.dart';

class OfflineIndicator extends StatelessWidget {
  final bool isOnline;
  final int pendingCount;
  final VoidCallback? onSyncTap;

  const OfflineIndicator({
    Key? key,
    required this.isOnline,
    this.pendingCount = 0,
    this.onSyncTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: isOnline ? const Color(0xFFECFDF5) : const Color(0xFFFEF3C7),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                isOnline ? Icons.cloud_done_rounded : Icons.cloud_off_rounded,
                size: 18,
                color: isOnline ? const Color(0xFF059669) : const Color(0xFFD97706),
              ),
              const SizedBox(width: 8),
              Text(
                isOnline
                    ? 'ONLINE — Data will sync automatically'
                    : 'OFFLINE — Data saved locally ($pendingCount pending)',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isOnline ? const Color(0xFF065F46) : const Color(0xFF92400E),
                ),
              ),
            ],
          ),
          if (pendingCount > 0 && onSyncTap != null)
            GestureDetector(
              onTap: onSyncTap,
              child: const Text(
                'Sync Now',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFDC2626),
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
