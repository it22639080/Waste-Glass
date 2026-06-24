import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';

class TimelineNumber extends StatelessWidget {
  const TimelineNumber({
    super.key,
    required this.number,
    this.isActive = false,
    this.isCompleted = false,
  });

  final int number;
  final bool isActive;
  final bool isCompleted;

  @override
  Widget build(BuildContext context) {
    final backgroundColor = isCompleted
        ? AppColors.primaryGreen
        : isActive
            ? AppColors.blueAccent
            : AppColors.lightGreen;
    final foregroundColor =
        isCompleted || isActive ? Colors.white : AppColors.darkGreen;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutBack,
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
        border: Border.all(
          color: isActive || isCompleted
              ? backgroundColor
              : AppColors.borderLight,
        ),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: AppColors.blueAccent.withOpacity(0.22),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
              ]
            : null,
      ),
      child: Center(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 220),
          transitionBuilder: (child, animation) {
            return ScaleTransition(scale: animation, child: child);
          },
          child: isCompleted
              ? const Icon(
                  Icons.check,
                  key: ValueKey('done'),
                  color: Colors.white,
                  size: 18,
                )
              : Text(
                  number.toString(),
                  key: ValueKey(number),
                  style: TextStyle(
                    color: foregroundColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
        ),
      ),
    );
  }
}
