import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';
import '../core/constants/app_sizes.dart';
import '../core/constants/app_text_styles.dart';
import 'status_badge.dart';
import 'supplier_icon_box.dart';

enum EcoHeroVariant { overview, completed, nextSupplier }

class EcoHeroCard extends StatelessWidget {
  const EcoHeroCard({
    super.key,
    required this.title,
    this.subtitle,
    this.dateText,
    this.message,
    this.variant = EcoHeroVariant.overview,
    this.supplierName,
    this.address,
    this.expectedKg,
    this.status,
  });

  final String title;
  final String? subtitle;
  final String? dateText;
  final String? message;
  final EcoHeroVariant variant;
  final String? supplierName;
  final String? address;
  final double? expectedKg;
  final String? status;

  bool get _isNextSupplier => variant == EcoHeroVariant.nextSupplier;

  @override
  Widget build(BuildContext context) {
    if (_isNextSupplier) {
      return _NextSupplierHero(
        title: title,
        supplierName: supplierName,
        address: address,
        expectedKg: expectedKg,
        status: status,
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.space20),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(AppSizes.radius24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGreen.withOpacity(0.24),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (variant == EcoHeroVariant.completed) ...[
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.16),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white.withOpacity(0.24)),
                    ),
                    child: const Icon(
                      Icons.check_circle_rounded,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                  const SizedBox(height: AppSizes.space14),
                ],
                if (dateText != null) ...[
                  Row(
                    children: [
                      Icon(
                        variant == EcoHeroVariant.completed
                            ? Icons.calendar_today_rounded
                            : Icons.calendar_today_rounded,
                        color: Colors.white.withOpacity(0.88),
                        size: 15,
                      ),
                      const SizedBox(width: AppSizes.space8),
                      Expanded(
                        child: Text(
                          dateText!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.caption.copyWith(
                            color: Colors.white.withOpacity(0.88),
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSizes.space14),
                ],
                Text(
                  title,
                  style: AppTextStyles.screenHeading.copyWith(
                    color: Colors.white,
                    fontSize: variant == EcoHeroVariant.completed ? 25 : 24,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: AppSizes.space8),
                  Text(
                    subtitle!,
                    style: AppTextStyles.cardTitle.copyWith(
                      color: Colors.white.withOpacity(0.92),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
                if (message != null) ...[
                  const SizedBox(height: AppSizes.space12),
                  Text(
                    message!,
                    style: AppTextStyles.caption.copyWith(
                      color: Colors.white.withOpacity(0.80),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: AppSizes.space10),
          _EcoDecoration(
            showCheck: variant == EcoHeroVariant.completed,
          ),
        ],
      ),
    );
  }
}

class _NextSupplierHero extends StatelessWidget {
  const _NextSupplierHero({
    required this.title,
    this.supplierName,
    this.address,
    this.expectedKg,
    this.status,
  });

  final String title;
  final String? supplierName;
  final String? address;
  final double? expectedKg;
  final String? status;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.cardPadding),
      decoration: BoxDecoration(
        color: AppColors.lightGreen,
        borderRadius: BorderRadius.circular(AppSizes.radius20),
        border: Border.all(color: AppColors.primaryGreen.withOpacity(0.12)),
        boxShadow: AppColors.softShadow,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SupplierIconBox(
            icon: Icons.storefront_rounded,
            backgroundColor: AppColors.surface,
            iconColor: AppColors.primaryGreen,
          ),
          const SizedBox(width: AppSizes.space12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: AppTextStyles.mutedLabel.copyWith(
                          color: AppColors.primaryGreen,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    StatusBadge(status: status ?? 'Next'),
                  ],
                ),
                const SizedBox(height: AppSizes.space6),
                Text(
                  supplierName ?? 'No supplier selected',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.cardTitle,
                ),
                if (address != null) ...[
                  const SizedBox(height: AppSizes.space10),
                  _InfoLine(icon: Icons.location_on_rounded, text: address!),
                ],
                if (expectedKg != null) ...[
                  const SizedBox(height: AppSizes.space6),
                  _InfoLine(
                    icon: Icons.local_drink_rounded,
                    text: '${expectedKg!.toStringAsFixed(0)} kg expected',
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: AppSizes.space8),
          const _SmallGlassDecoration(),
        ],
      ),
    );
  }
}

class _InfoLine extends StatelessWidget {
  const _InfoLine({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 15, color: AppColors.primaryGreen),
        const SizedBox(width: AppSizes.space6),
        Expanded(
          child: Text(
            text,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.caption.copyWith(color: AppColors.textDark),
          ),
        ),
      ],
    );
  }
}

class _EcoDecoration extends StatelessWidget {
  const _EcoDecoration({this.showCheck = false});

  final bool showCheck;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 94,
      height: 128,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.13),
              shape: BoxShape.circle,
            ),
          ),
          Positioned(
            top: 8,
            right: 6,
            child: Icon(
              Icons.recycling_rounded,
              color: Colors.white.withOpacity(0.32),
              size: 50,
            ),
          ),
          Positioned(
            bottom: 10,
            left: 20,
            child: Transform.rotate(
              angle: -0.16,
              child: const _Bottle(height: 74),
            ),
          ),
          Positioned(
            bottom: 20,
            right: 12,
            child: Transform.rotate(
              angle: 0.18,
              child: const _Bottle(height: 58, opacity: 0.74),
            ),
          ),
          Positioned(
            left: 6,
            bottom: 38,
            child: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.18),
                shape: BoxShape.circle,
              ),
              child: Icon(
                showCheck ? Icons.check_rounded : Icons.eco_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SmallGlassDecoration extends StatelessWidget {
  const _SmallGlassDecoration();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 58,
      height: 86,
      child: Stack(
        children: [
          Positioned(
            top: 6,
            right: 2,
            child: Icon(
              Icons.recycling_rounded,
              size: 34,
              color: AppColors.primaryGreen.withOpacity(0.20),
            ),
          ),
          Positioned(
            bottom: 2,
            left: 8,
            child: Transform.rotate(
              angle: -0.14,
              child: Container(
                width: 22,
                height: 58,
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: AppColors.primaryGreen.withOpacity(0.22),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 8,
            right: 8,
            child: Transform.rotate(
              angle: 0.14,
              child: Container(
                width: 18,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.blueAccent.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.blueAccent.withOpacity(0.16),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Bottle extends StatelessWidget {
  const _Bottle({required this.height, this.opacity = 0.92});

  final double height;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: height * 0.22,
          height: height * 0.22,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(opacity),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        Container(
          width: height * 0.36,
          height: height * 0.72,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(opacity),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Center(
            child: Container(
              width: height * 0.18,
              height: height * 0.26,
              decoration: BoxDecoration(
                color: AppColors.primaryGreen.withOpacity(0.45),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
