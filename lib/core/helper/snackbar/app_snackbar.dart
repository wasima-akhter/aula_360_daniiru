import 'package:flutter/material.dart';

enum UiSnackbarType { success, error, warning, info }

class UiSnackbar {
  static void show(
    BuildContext context, {
    required String message,
    String? title,
    UiSnackbarType type = UiSnackbarType.info,
  }) {
    final config = _config(type);

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: config.color,
          duration: const Duration(seconds: 3),
          content: Row(
            children: [
              Icon(config.icon, color: Colors.white),
              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (title != null)
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                        ),
                      ),

                    Text(
                      message,
                      style: const TextStyle(color: Colors.white, fontSize: 15.5),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
  }

  static _SnackbarConfig _config(UiSnackbarType type) {
    switch (type) {
      case UiSnackbarType.success:
        return _SnackbarConfig(
          color: Colors.green,
          icon: Icons.check_circle_outline,
        );

      case UiSnackbarType.error:
        return _SnackbarConfig(color: Colors.red, icon: Icons.error_outline);

      case UiSnackbarType.warning:
        return _SnackbarConfig(
          color: Colors.orange,
          icon: Icons.warning_amber_outlined,
        );

      case UiSnackbarType.info:
        return _SnackbarConfig(color: Colors.blue, icon: Icons.info_outline);
    }
  }
}

class _SnackbarConfig {
  final Color color;
  final IconData icon;

  const _SnackbarConfig({required this.color, required this.icon});
}
