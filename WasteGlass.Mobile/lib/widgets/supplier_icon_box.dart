import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';
import '../core/constants/app_sizes.dart';

class SupplierIconBox extends StatelessWidget {
  const SupplierIconBox({
    super.key,
    this.icon = Icons.recycling,
    this.backgroundColor = AppColors.lightGreen,
    this.iconColor = AppColors.primaryGreen,
    this.size = AppSizes.iconBox,
  });

  final IconData icon;
  final Color backgroundColor;
  final Color iconColor;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppSizes.radius16),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Icon(icon, color: iconColor, size: size * 0.48),
    );
  }
}
