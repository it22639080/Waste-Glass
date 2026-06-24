import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';
import '../core/constants/app_sizes.dart';
import '../core/constants/app_text_styles.dart';
import '../data/models/trip_report_model.dart';
import 'premium_card.dart';
import 'shortfall_badge.dart';
import 'status_badge.dart';
import 'supplier_icon_box.dart';

class SupplierReportCard extends StatelessWidget {
  SupplierReportCard({
    super.key,
    required this.item,
    this.address,
    double? expectedKg,
    double? collectedKg,
    bool? shortfall,
  })  : expectedKg = expectedKg ?? item.expectedKg,
        collectedKg = collectedKg ?? item.totalKg,
        shortfall = shortfall ?? item.totalKg < item.expectedKg;

  final SupplierReportItemModel item;
  final String? address;
  final double expectedKg;
  final double collectedKg;
  final bool shortfall;

  @override
  Widget build(BuildContext context) {
    final shortfallKg = expectedKg - collectedKg;
    final collectedColor =
        shortfall ? AppColors.warningOrange : AppColors.primaryGreen;

    return PremiumCard(
      margin: const EdgeInsets.only(bottom: AppSizes.space12),
      borderColor: shortfall
          ? AppColors.warningOrange.withOpacity(0.32)
          : AppColors.borderLight,
      backgroundColor: shortfall
          ? AppColors.warningOrange.withOpacity(0.06)
          : AppColors.surface,
      showShadow: !shortfall,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SupplierIconBox(
                icon: shortfall
                    ? Icons.warning_amber_rounded
                    : Icons.storefront_rounded,
                backgroundColor: shortfall
                    ? AppColors.warningOrange.withOpacity(0.10)
                    : AppColors.lightGreen,
                iconColor: shortfall
                    ? AppColors.warningOrange
                    : AppColors.primaryGreen,
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
                            item.supplierName,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.cardTitle,
                          ),
                        ),
                        const SizedBox(width: AppSizes.space8),
                        shortfall
                            ? const ShortfallBadge(message: 'Shortfall')
                            : const StatusBadge(status: 'Collected'),
                      ],
                    ),
                    if (address != null) ...[
                      const SizedBox(height: AppSizes.space6),
                      Text(
                        address!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.caption,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.space14),
          Row(
            children: [
              Expanded(
                child: _KgColumn(
                  label: 'Expected',
                  value: '${expectedKg.toStringAsFixed(0)} kg',
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(width: AppSizes.space10),
              Expanded(
                child: _KgColumn(
                  label: 'Collected',
                  value: '${collectedKg.toStringAsFixed(0)} kg',
                  color: collectedColor,
                ),
              ),
              const SizedBox(width: AppSizes.space10),
              Expanded(
                child: _KgColumn(
                  label: 'Estimated',
                  value: '${expectedKg.toStringAsFixed(0)} kg',
                  color: AppColors.blueAccent,
                ),
              ),
            ],
          ),
          if (shortfall) ...[
            const SizedBox(height: AppSizes.space10),
            Text(
              '${shortfallKg.toStringAsFixed(0)} kg less',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.warningOrange,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _KgColumn extends StatelessWidget {
  const _KgColumn({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppSizes.radius16),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTextStyles.caption),
          const SizedBox(height: AppSizes.space4),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              maxLines: 1,
              style: AppTextStyles.cardTitle.copyWith(color: color),
            ),
          ),
        ],
      ),
    );
  }
}
