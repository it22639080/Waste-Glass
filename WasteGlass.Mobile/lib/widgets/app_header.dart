import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';
import '../core/constants/app_sizes.dart';
import '../core/constants/app_text_styles.dart';

class AppHeader extends StatelessWidget {
  const AppHeader({
    super.key,
    required this.title,
    this.leadingIcon,
    this.trailing = const [],
    this.onBack,
    this.onMenu,
  });

  final String title;
  final IconData? leadingIcon;
  final List<Widget> trailing;
  final VoidCallback? onBack;
  final VoidCallback? onMenu;

  @override
  Widget build(BuildContext context) {
    final icon = leadingIcon ??
        (onBack != null ? Icons.arrow_back_rounded : Icons.menu_rounded);

    return Row(
      children: [
        _HeaderIconButton(
          icon: icon,
          onTap: onBack ?? onMenu ?? () {},
        ),
        const SizedBox(width: AppSizes.space12),
        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.screenHeading,
          ),
        ),
        ...trailing.map(
          (widget) => Padding(
            padding: const EdgeInsets.only(left: AppSizes.space10),
            child: widget,
          ),
        ),
      ],
    );
  }
}

class HeaderIconButton extends StatelessWidget {
  const HeaderIconButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.showBadge = false,
  });

  final IconData icon;
  final VoidCallback onTap;
  final bool showBadge;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        _HeaderIconButton(icon: icon, onTap: onTap),
        if (showBadge)
          Positioned(
            top: 7,
            right: 8,
            child: Container(
              width: 9,
              height: 9,
              decoration: BoxDecoration(
                color: AppColors.dangerRed,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 1.5),
              ),
            ),
          ),
      ],
    );
  }
}

class HeaderAvatar extends StatelessWidget {
  const HeaderAvatar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: AppColors.lightGreen,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.borderLight),
      ),
      child: const Icon(
        Icons.person_rounded,
        color: AppColors.darkGreen,
        size: 22,
      ),
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  const _HeaderIconButton({
    required this.icon,
    required this.onTap,
  });

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.borderLight),
            boxShadow: AppColors.softShadow,
          ),
          child: Icon(icon, color: AppColors.darkGreen),
        ),
      ),
    );
  }
}
