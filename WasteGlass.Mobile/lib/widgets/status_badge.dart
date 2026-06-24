import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';
import '../core/constants/app_text_styles.dart';

class StatusBadge extends StatelessWidget {
  const StatusBadge({
    super.key,
    required this.status,
    this.icon,
  });

  final String status;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      'Collected' => AppColors.primaryGreen,
      'Next' => AppColors.primaryGreen,
      'Shortfall' => AppColors.warningOrange,
      _ => AppColors.textGrey,
    };
    final badgeIcon = icon ??
        switch (status) {
      'Collected' => Icons.check_circle,
      'Next' => Icons.arrow_forward_rounded,
      'Shortfall' => Icons.warning_amber_rounded,
      _ => Icons.schedule,
    };
    final backgroundColor = switch (status) {
      'Collected' || 'Next' => AppColors.lightGreen,
      'Shortfall' => AppColors.warningOrange.withOpacity(0.12),
      _ => const Color(0xFFF2F4F7),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withOpacity(0.18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(badgeIcon, color: color, size: 13),
          const SizedBox(width: 5),
          Text(
            status,
            style: AppTextStyles.mutedLabel.copyWith(
              color: color,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
