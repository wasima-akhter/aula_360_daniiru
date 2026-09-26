import 'package:flutter/material.dart';

import 'core/router/routes.dart';
import 'utils/app_keys/app_keys.dart';

void main() {
  runApp(const Aula360App());
}

class Aula360App extends StatelessWidget {
  const Aula360App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      scaffoldMessengerKey: AppKeys.scaffoldMessengerKey,
      routerConfig: AppRouter.router,
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Inter',
        scaffoldBackgroundColor: Colors.white,
      ),
    );
  }
}
