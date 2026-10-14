import '../../../features/share/export/screen_export.dart';
import '../../../utils/app_keys/app_keys.dart';

enum SnackbarType { success, error, warning, info }

class ApiSnackbar {
  /// Shows a decent, polished, non-technical snackbar message.
  /// When [type] is [SnackbarType.error], the message is automatically checked
  /// and resolved through [AppErrorResolver] to eliminate raw API or stack-trace text,
  /// replacing it with an on-point message and optional directional ("directory") guidance.
  static void show(
    String message, {
    String? title,
    String? directive,
    SnackbarType type = SnackbarType.error,
  }) {
    final messenger = AppKeys.scaffoldMessengerKey.currentState;

    if (messenger == null) {
      debugPrint('Snackbar unavailable: $message');
      return;
    }

    String displayTitle = title ?? '';
    String displayMessage = message;
    String? displayDirective = directive;

    if (type == SnackbarType.error) {
      final resolved = AppErrorResolver.resolve(
        message,
        fallbackDirective: directive,
      );
      if (displayTitle.isEmpty) {
        displayTitle = resolved.title;
      }
      displayMessage = resolved.message;
      displayDirective = displayDirective ?? resolved.directive;
    }

    _render(
      messenger: messenger,
      title: displayTitle,
      message: displayMessage,
      directive: displayDirective,
      type: type,
    );
  }

  /// Directly displays a [UserFriendlyMessage] with structured title, message, and directional guidance.
  static void showUserMessage(
    UserFriendlyMessage userMessage, {
    SnackbarType type = SnackbarType.error,
  }) {
    final messenger = AppKeys.scaffoldMessengerKey.currentState;

    if (messenger == null) {
      debugPrint('Snackbar unavailable: ${userMessage.displayMessage}');
      return;
    }

    _render(
      messenger: messenger,
      title: userMessage.title,
      message: userMessage.message,
      directive: userMessage.directive,
      type: type,
    );
  }

  static void _render({
    required ScaffoldMessengerState messenger,
    required String title,
    required String message,
    required String? directive,
    required SnackbarType type,
  }) {
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          duration: Duration(seconds: directive != null ? 5 : 3),
          backgroundColor: _color(type),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (title.isNotEmpty) ...[
                Row(
                  children: [
                    Icon(_headerIcon(type), size: 18, color: Colors.white),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        title,
                        style: TxtStyle.titleLarge(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15.5.sp,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
              ],
              Text(
                message,
                style: TxtStyle.titleMedium(
                  fontSize: 14.sp,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (directive != null && directive.trim().isNotEmpty) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(top: 2),
                        child: Icon(
                          Icons.arrow_right_alt_rounded,
                          size: 16,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          directive,
                          style: TxtStyle.bodySmall(
                            fontSize: 12.5.sp,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      );
  }

  static IconData _headerIcon(SnackbarType type) {
    switch (type) {
      case SnackbarType.success:
        return Icons.check_circle_rounded;
      case SnackbarType.error:
        return Icons.error_rounded;
      case SnackbarType.warning:
        return Icons.warning_rounded;
      case SnackbarType.info:
        return Icons.info_rounded;
    }
  }

  static Color _color(SnackbarType type) {
    switch (type) {
      case SnackbarType.success:
        return const Color(0xFF1B8755);
      case SnackbarType.error:
        return const Color(0xFFD32F2F);
      case SnackbarType.warning:
        return const Color(0xFFE65100);
      case SnackbarType.info:
        return const Color(0xFF1976D2);
    }
  }
}
