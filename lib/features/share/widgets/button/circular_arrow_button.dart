import 'package:aula360/utils/color/app_colors.dart';
import 'package:flutter/material.dart';

class CircularArrowButton extends StatelessWidget {
  final VoidCallback onTap;
  final IconData icon;

  const CircularArrowButton({
    required this.onTap,
    this.icon = Icons.arrow_forward,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.primaryColor,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Container(
          width: 48,
          height: 48,
          decoration: const BoxDecoration(
            color: AppColors.primaryColor,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.arrow_back_ios_new,
            color: AppColors.white,
            size: 20,
          ),
        ),
      ),
    );
  }
}
