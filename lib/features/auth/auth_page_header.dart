import 'package:flutter/material.dart';

import '../../utils/color/app_colors.dart';
import '../share/widgets/button/app_logo.dart';

class AulaPageHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const AulaPageHeader({
    super.key,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const AulaLogo(width: 125),
        const SizedBox(height: 24),
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: AppColors.text,
            fontSize: 24.5,
            fontWeight: FontWeight.w800,
            letterSpacing: -.4,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: AppColors.secondaryText,
            fontSize: 14,
            height: 1.45,
          ),
        ),
      ],
    );
  }
}
