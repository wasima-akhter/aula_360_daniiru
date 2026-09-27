import 'package:flutter/material.dart';

import '../../../../utils/color/app_colors.dart';

class AulaLogo extends StatelessWidget {
  final double width;

  const AulaLogo({super.key, this.width = 120});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/app_logo.png',
      width: width,
      fit: BoxFit.contain,
      errorBuilder: (_, _, _) {
        return Text(
          'AULA360°',
          style: TextStyle(
            fontSize: width * .20,
            fontWeight: FontWeight.w900,
            color: AppColors.primary,
            letterSpacing: -1,
          ),
        );
      },
    );
  }
}
