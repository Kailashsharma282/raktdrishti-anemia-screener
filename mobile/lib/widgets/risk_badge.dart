import 'package:flutter/material.dart';
import '../core/constants/app_constants.dart';

class RiskBadge extends StatelessWidget {
  final String riskCategory;
  final double? fontSize;
  final bool showIcon;

  const RiskBadge({
    Key? key,
    required this.riskCategory,
    this.fontSize = 13,
    this.showIcon = true,
  }) : super(key: key);

  Color get _color {
    switch (riskCategory.toUpperCase()) {
      case 'SEVERE':
        return AppConstants.colorSevere;
      case 'MODERATE':
        return AppConstants.colorModerate;
      case 'MILD':
        return AppConstants.colorMild;
      default:
        return AppConstants.colorNormal;
    }
  }

  IconData get _icon {
    switch (riskCategory.toUpperCase()) {
      case 'SEVERE':
        return Icons.warning_rounded;
      case 'MODERATE':
        return Icons.error_outline_rounded;
      case 'MILD':
        return Icons.info_outline_rounded;
      default:
        return Icons.check_circle_outline_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: _color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _color, width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showIcon) ...[
            Icon(_icon, size: fontSize! + 3, color: _color),
            const SizedBox(width: 5),
          ],
          Text(
            riskCategory.toUpperCase(),
            style: TextStyle(
              color: _color,
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
