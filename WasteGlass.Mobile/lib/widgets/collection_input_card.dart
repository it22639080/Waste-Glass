import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';
import '../core/constants/app_sizes.dart';
import '../core/constants/app_text_styles.dart';
import 'premium_card.dart';
import 'supplier_icon_box.dart';

class CollectionInputCard extends StatelessWidget {
  const CollectionInputCard({
    super.key,
    required this.enabled,
    required this.clearController,
    required this.colouredController,
    required this.selectedCondition,
    required this.onConditionChanged,
    this.error,
    this.conditions = const ['Good', 'Mixed', 'Damaged'],
  });

  final bool enabled;
  final TextEditingController clearController;
  final TextEditingController colouredController;
  final String selectedCondition;
  final ValueChanged<String> onConditionChanged;
  final String? error;
  final List<String> conditions;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1 : 0.55,
      child: PremiumCard(
        showShadow: false,
        backgroundColor: enabled ? AppColors.surface : const Color(0xFFF8FAFC),
        child: IgnorePointer(
          ignoring: !enabled,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Collection Details', style: AppTextStyles.cardTitle),
              const SizedBox(height: AppSizes.space14),
              Row(
                children: [
                  Expanded(
                    child: _GlassInputBox(
                      controller: clearController,
                      label: 'Clear Glass',
                      icon: Icons.water_drop_outlined,
                    ),
                  ),
                  const SizedBox(width: AppSizes.space10),
                  Expanded(
                    child: _GlassInputBox(
                      controller: colouredController,
                      label: 'Coloured Glass',
                      icon: Icons.local_drink_outlined,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.space16),
              Text('Condition', style: AppTextStyles.mutedLabel),
              const SizedBox(height: AppSizes.space8),
              Row(
                children: [
                  for (final option in conditions) ...[
                    Expanded(
                      child: InkWell(
                        onTap: () => onConditionChanged(option),
                        borderRadius: BorderRadius.circular(AppSizes.radius16),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 160),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: selectedCondition == option
                                ? AppColors.lightGreen
                                : AppColors.surface,
                            borderRadius:
                                BorderRadius.circular(AppSizes.radius16),
                            border: Border.all(
                              color: selectedCondition == option
                                  ? AppColors.primaryGreen
                                  : AppColors.borderLight,
                              width: selectedCondition == option ? 1.4 : 1,
                            ),
                          ),
                          child: Text(
                            option,
                            textAlign: TextAlign.center,
                            style: AppTextStyles.mutedLabel.copyWith(
                              color: selectedCondition == option
                                  ? AppColors.primaryGreen
                                  : AppColors.textGrey,
                              fontWeight: selectedCondition == option
                                  ? FontWeight.w900
                                  : FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                    if (option != conditions.last)
                      const SizedBox(width: AppSizes.space8),
                  ],
                ],
              ),
              if (error != null) ...[
                const SizedBox(height: AppSizes.space10),
                Text(
                  error!,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.dangerRed,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _GlassInputBox extends StatelessWidget {
  const _GlassInputBox({
    required this.controller,
    required this.label,
    required this.icon,
  });

  final TextEditingController controller;
  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SupplierIconBox(
          icon: icon,
          size: 34,
          backgroundColor: AppColors.lightGreen,
          iconColor: AppColors.primaryGreen,
        ),
        const SizedBox(height: AppSizes.space8),
        TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            labelText: label,
            suffixText: 'kg',
          ),
        ),
      ],
    );
  }
}
