import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  static const TextStyle screenHeading = TextStyle(
    fontSize: 28,
    height: 1.08,
    fontWeight: FontWeight.w900,
    letterSpacing: 0,
    color: AppColors.darkGreen,
  );

  static const TextStyle screenSubtitle = TextStyle(
    fontSize: 14,
    height: 1.35,
    fontWeight: FontWeight.w500,
    color: AppColors.textGrey,
  );

  static const TextStyle cardTitle = TextStyle(
    fontSize: 16,
    height: 1.25,
    fontWeight: FontWeight.w800,
    color: AppColors.textDark,
  );

  static const TextStyle mutedLabel = TextStyle(
    fontSize: 12,
    height: 1.25,
    fontWeight: FontWeight.w600,
    color: AppColors.textGrey,
  );

  static const TextStyle statNumber = TextStyle(
    fontSize: 24,
    height: 1,
    fontWeight: FontWeight.w900,
    color: AppColors.darkGreen,
  );

  static const TextStyle statNumberBlue = TextStyle(
    fontSize: 24,
    height: 1,
    fontWeight: FontWeight.w900,
    color: AppColors.blueAccent,
  );

  static const TextStyle button = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w800,
    color: Colors.white,
  );

  static const TextStyle title = TextStyle(
    fontSize: 24,
    height: 1.12,
    fontWeight: FontWeight.w900,
    color: AppColors.darkGreen,
  );

  static const TextStyle section = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w800,
    color: AppColors.textDark,
  );

  static const TextStyle body = TextStyle(
    fontSize: 14,
    height: 1.35,
    color: AppColors.textDark,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 12,
    height: 1.3,
    color: AppColors.textGrey,
  );
}
