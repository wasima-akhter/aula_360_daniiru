import 'package:aula360/utils/color/app_colors.dart';
import 'package:flutter/material.dart';

class CustomBackButton extends StatelessWidget {
  final VoidCallback onTap;
  final Color backgroundColor;
  final Color borderColor;
  final double borderRadius;

  final Icon icon;

  const CustomBackButton({
    super.key,
    required this.onTap,
    this.backgroundColor = AppColors.backgroundColor,
    this.borderColor = AppColors.backgroundsLinesColor,
    this.borderRadius = 23,
    // Default height
    this.icon = const Icon(Icons.arrow_back, size: 24),
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(3),
        child: Container(
          padding: EdgeInsets.zero,
          margin: EdgeInsets.zero,
          decoration: BoxDecoration(
            color: backgroundColor.withValues(alpha: 0.1),
            border: Border.all(color: borderColor, width: 1),
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          child: icon,
        ),
      ),
    );
  }
}

class AuthBackButton extends StatelessWidget {
  final String title;

  const AuthBackButton({super.key, this.title = ''});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: const Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 17,
            color: AppColors.primaryDark,
          ),
        ),
        if (title.isNotEmpty) ...[
          const SizedBox(width: 7),
          Text(
            title,
            style: const TextStyle(
              color: AppColors.primaryDark,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ],
    );
  }
}
