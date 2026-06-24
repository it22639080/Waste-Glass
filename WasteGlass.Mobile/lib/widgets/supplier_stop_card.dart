import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';
import '../core/constants/app_sizes.dart';
import '../core/constants/app_text_styles.dart';
import 'premium_card.dart';
import 'status_badge.dart';
import 'supplier_icon_box.dart';
import 'timeline_number.dart';

class SupplierStopCard extends StatelessWidget {
  const SupplierStopCard({
    super.key,
    required this.stopOrder,
    required this.supplierName,
    required this.address,
    required this.expectedKg,
    required this.status,
    this.isNext = false,
    this.isCollected = false,
    this.isLast = false,
  });

  final int stopOrder;
  final String supplierName;
  final String address;
  final double expectedKg;
  final String status;
  final bool isNext;
  final bool isCollected;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              TimelineNumber(
                number: stopOrder,
                isActive: isNext,
                isCompleted: isCollected,
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    decoration: BoxDecoration(
                      color: isCollected
                          ? AppColors.primaryGreen.withOpacity(0.42)
                          : AppColors.borderLight,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: AppSizes.space12),
          Expanded(
            child: PremiumCard(
              margin: EdgeInsets.only(bottom: isLast ? 0 : AppSizes.space14),
              borderColor:
                  isNext ? AppColors.primaryGreen : AppColors.borderLight,
              backgroundColor: isNext ? AppColors.lightGreen : AppColors.surface,
              showShadow: isNext,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SupplierIconBox(
                    icon: isCollected
                        ? Icons.check_rounded
                        : Icons.storefront_rounded,
                    backgroundColor:
                        isNext ? AppColors.surface : AppColors.lightGreen,
                    iconColor: isCollected
                        ? AppColors.primaryGreen
                        : AppColors.darkGreen,
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
                                supplierName,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyles.cardTitle,
                              ),
                            ),
                            const SizedBox(width: AppSizes.space8),
                            StatusBadge(status: status),
                          ],
                        ),
                        const SizedBox(height: AppSizes.space8),
                        Text(
                          address,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.caption,
                        ),
                        const SizedBox(height: AppSizes.space12),
                        Wrap(
                          spacing: AppSizes.space8,
                          runSpacing: AppSizes.space8,
                          children: [
                            _MiniStopChip(
                              icon: Icons.scale_rounded,
                              label:
                                  '${expectedKg.toStringAsFixed(0)} kg expected',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniStopChip extends StatelessWidget {
  const _MiniStopChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppColors.primaryGreen, size: 14),
          const SizedBox(width: 5),
          Text(
            label,
            style: AppTextStyles.mutedLabel.copyWith(
              color: AppColors.textDark,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
