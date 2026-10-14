import 'package:flutter/widgets.dart';

import 'core/app/app.dart';
import 'core/app/bootstrap.dart';

export 'core/app/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await bootstrap(app: const App());
}
