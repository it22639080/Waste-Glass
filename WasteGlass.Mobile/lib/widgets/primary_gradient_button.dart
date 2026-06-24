import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';
import '../core/constants/app_sizes.dart';
import '../core/constants/app_text_styles.dart';

class PrimaryGradientButton extends StatefulWidget {
  const PrimaryGradientButton({
    super.key,
    String? text,
    String? label,
    required this.onPressed,
    this.icon,
    bool? loading,
    bool? isLoading,
    this.enabled = true,
  })  : text = text ?? label ?? '',
        loading = loading ?? isLoading ?? false;

  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool loading;
  final bool enabled;

  bool get isEnabled => enabled && onPressed != null && !loading;

  @override
  State<PrimaryGradientButton> createState() => _PrimaryGradientButtonState();
}

class _PrimaryGradientButtonState extends State<PrimaryGradientButton> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed == value) return;
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final enabled = widget.isEnabled;

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 180),
      opacity: enabled ? 1 : 0.55,
      child: AnimatedScale(
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        scale: _pressed && enabled ? 0.97 : 1,
        child: Listener(
          onPointerDown: (_) {
            if (enabled) _setPressed(true);
          },
          onPointerUp: (_) => _setPressed(false),
          onPointerCancel: (_) => _setPressed(false),
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: enabled ? AppColors.primaryGradient : null,
              color: enabled ? null : AppColors.borderLight,
              borderRadius: BorderRadius.circular(AppSizes.radius16),
              boxShadow: enabled
                  ? [
                      BoxShadow(
                        color: AppColors.primaryGreen.withOpacity(0.24),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                    ]
                  : null,
            ),
            child: SizedBox(
              width: double.infinity,
              height: AppSizes.buttonHeight,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: enabled ? widget.onPressed : null,
                  borderRadius: BorderRadius.circular(AppSizes.radius16),
                  child: Center(
                    child: widget.loading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.2,
                              color: Colors.white,
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (widget.icon != null) ...[
                                Icon(widget.icon,
                                    color: Colors.white, size: 20),
                                const SizedBox(width: AppSizes.space8),
                              ],
                              Flexible(
                                child: Text(
                                  widget.text,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTextStyles.button,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
