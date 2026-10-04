import '../../../features/share/export/screen_export.dart';
import '../../../utils/app_keys/app_keys.dart';

enum SnackbarType { success, error, warning, info }

class ApiSnackbar {
  static void show(
    String message, {
    String? title,
    SnackbarType type = SnackbarType.error,
  }) {
    final messenger = AppKeys.scaffoldMessengerKey.currentState;

    if (messenger == null) {
      print("Snackbar unavailable: $message");
      return;
    }

    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 3),
          backgroundColor: _color(type),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (title != null && title.isNotEmpty)
                Text(
                  title,
                  style: TxtStyle.titleLarge(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 17.sp,
                  ),
                ),
              if (title != null && title.isNotEmpty) const SizedBox(height: 4),
              Text(
                message,
                style: TxtStyle.titleLarge(
                  fontSize: 16.sp,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      );
  }

  static Color _color(SnackbarType type) {
    switch (type) {
      case SnackbarType.success:
        return Colors.green;
      case SnackbarType.error:
        return Colors.red;
      case SnackbarType.warning:
        return Colors.orange;
      case SnackbarType.info:
        return Colors.blue;
    }
  }
}
