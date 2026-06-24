import 'package:flutter/material.dart';

import 'primary_gradient_button.dart';

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return PrimaryGradientButton(
      label: label,
      onPressed: onPressed,
      isLoading: isLoading,
      icon: icon ?? Icons.check_circle_outline,
    );
  }
}
