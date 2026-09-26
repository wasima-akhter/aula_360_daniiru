import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DeviceUtils {
  static void lockDevicePortrait() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }
}

double bottomPadding(BuildContext context) =>
    MediaQuery.of(context).viewPadding.bottom;
