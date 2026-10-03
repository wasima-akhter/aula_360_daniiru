import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'core/router/routes.dart';
import 'core/theme/light_theme.dart';
import 'utils/app_keys/app_keys.dart';

void main() {
  runApp(ProviderScope(child: const Aula360App()));
}

class Aula360App extends StatelessWidget {
  const Aula360App({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(390, 884),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return child!;
      },
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        scaffoldMessengerKey: AppKeys.scaffoldMessengerKey,
        routerConfig: AppRouter.router,
        theme: lightTheme,
      ),
    );
  }
}
