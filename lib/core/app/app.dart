import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../router/routes.dart';
import '../service/language/language_provider.dart';
import '../theme/light_theme.dart';
import '../../utils/app_keys/app_keys.dart';

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final langState = ref.watch(languageProvider).valueOrNull;
    final currentLocale = langState != null
        ? Locale(langState.language.code)
        : const Locale('en');

    return ScreenUtilInit(
      designSize: const Size(390, 884),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp.router(
          debugShowCheckedModeBanner: false,
          title: 'Aula 360',
          scaffoldMessengerKey: AppKeys.scaffoldMessengerKey,
          routerConfig: AppRouter.router,
          theme: lightTheme,
          locale: currentLocale,
          supportedLocales: const [
            Locale('en'),
            Locale('es'),
          ],
        );
      },
    );
  }
}
