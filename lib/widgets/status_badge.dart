import 'package:flutter/material.dart';
import '../models/booking.dart';
import '../theme/app_theme.dart';

class StatusBadge extends StatelessWidget {
  final BookingStatus status;
  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    late Color bg;
    late Color fg;
    late IconData icon;

    switch (status) {
      case BookingStatus.confirmed:
        bg = AppColors.successBg;
        fg = AppColors.success;
        icon = Icons.check_circle_rounded;
        break;
      case BookingStatus.completed:
        bg = AppColors.border;
        fg = AppColors.textSecondary;
        icon = Icons.task_alt_rounded;
        break;
      case BookingStatus.cancelled:
        bg = AppColors.dangerBg;
        fg = AppColors.danger;
        icon = Icons.cancel_rounded;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: fg),
          const SizedBox(width: 4),
          Text(
            status.label,
            style: TextStyle(
              color: fg,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
