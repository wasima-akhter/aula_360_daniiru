import 'package:flutter/material.dart';

import '../states/app_loader.dart';

class AppPaginationLoader extends StatelessWidget {
  final double height;

  const AppPaginationLoader({super.key, this.height = 56});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: const Center(child: AppLoader()),
    );
  }
}
