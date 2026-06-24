import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';
import '../core/constants/app_text_styles.dart';
import '../data/models/supplier_stop_model.dart';
import 'status_badge.dart';

class StopCard extends StatelessWidget {
  const StopCard({super.key, required this.stop});

  final SupplierStopModel stop;

  @override
  Widget build(BuildContext context) {
    final borderColor = stop.isNext
        ? AppColors.secondary
        : stop.isCollected
            ? AppColors.success.withOpacity(0.35)
            : AppColors.border;
    final backgroundColor = stop.isNext
        ? AppColors.secondary.withOpacity(0.08)
        : stop.isCollected
            ? AppColors.success.withOpacity(0.06)
            : AppColors.surface;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: borderColor,
          width: stop.isNext ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: stop.isCollected
                    ? AppColors.success
                    : AppColors.primary.withOpacity(0.12),
                child: stop.isCollected
                    ? const Icon(Icons.check, color: Colors.white, size: 18)
                    : Text(
                        stop.stopOrder.toString(),
                        style: const TextStyle(
                          color: AppColors.primaryDark,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      stop.supplierName,
                      style: AppTextStyles.section.copyWith(
                        color: stop.isCollected
                            ? AppColors.textSecondary
                            : AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(stop.supplierCode, style: AppTextStyles.caption),
                  ],
                ),
              ),
              StatusBadge(status: stop.status),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            stop.address,
            style: AppTextStyles.body.copyWith(
              color: stop.isCollected
                  ? AppColors.textSecondary
                  : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _InfoChip(label: 'Expected', value: '${stop.expectedKg.toStringAsFixed(0)} kg'),
              const SizedBox(width: 8),
              _InfoChip(
                label: 'From previous',
                value: '${stop.distanceFromPreviousKm.toStringAsFixed(2)} km',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: AppTextStyles.caption),
            const SizedBox(height: 2),
            Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}
