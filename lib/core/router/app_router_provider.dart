import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'router_refresh_notifier.dart';

final authRouterRefreshNotifierProvider = Provider<AuthRouterRefreshNotifier>((
  ref,
) {
  return AuthRouterRefreshNotifier(ref);
});
