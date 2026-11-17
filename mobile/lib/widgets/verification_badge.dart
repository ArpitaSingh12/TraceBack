import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class VerificationBadge extends StatelessWidget {
  final String status;

  const VerificationBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final normalized = status.toLowerCase();
    Color bgColor;
    Color textColor;
    IconData icon;
    String label;

    if (normalized.contains('verify') || normalized == 'approved') {
      bgColor = AppTheme.sageLight;
      textColor = AppTheme.verifiedGreen;
      icon = Icons.check_circle_rounded;
      label = 'Verified';
    } else if (normalized.contains('reject')) {
      bgColor = const Color(0xFFFDE8E8);
      textColor = AppTheme.rejectedRed;
      icon = Icons.cancel_rounded;
      label = 'Rejected';
    } else {
      bgColor = AppTheme.warmGoldLight;
      textColor = AppTheme.pendingGold;
      icon = Icons.schedule_rounded;
      label = 'Pending Review';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: textColor.withValues(alpha: 0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: textColor),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
