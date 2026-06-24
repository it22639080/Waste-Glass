import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';
import '../core/constants/app_sizes.dart';
import '../core/constants/app_text_styles.dart';
import 'premium_card.dart';
import 'supplier_icon_box.dart';

class MetricCard extends StatelessWidget {
  const MetricCard({
    super.key,
    String? title,
    String? label,
    required this.value,
    required this.icon,
    this.accentColor = AppColors.primaryGreen,
    this.backgroundColor = AppColors.lightGreen,
    this.subtitle,
  }) : title = title ?? label ?? '';

  final String title;
  final String value;
  final IconData icon;
  final Color accentColor;
  final Color backgroundColor;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return PremiumCard(
      backgroundColor: backgroundColor,
      borderColor: accentColor.withOpacity(0.10),
      showShadow: false,
      padding: const EdgeInsets.all(AppSizes.space14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          SupplierIconBox(
            icon: icon,
            backgroundColor: AppColors.surface.withOpacity(0.72),
            iconColor: accentColor,
            size: 38,
          ),
          const SizedBox(height: AppSizes.space12),
          Text(title, style: AppTextStyles.mutedLabel),
          const SizedBox(height: AppSizes.space6),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              maxLines: 1,
              style: AppTextStyles.statNumber.copyWith(color: accentColor),
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: AppSizes.space4),
            Text(
              subtitle!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.caption,
            ),
          ],
        ],
      ),
    );
  }
}
