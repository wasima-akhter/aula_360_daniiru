import '../../export/screen_export.dart';

enum AppDialogType { info, success, warning, error, custom }

class AppDialog {
  static Future<Object?> show({
    required BuildContext context,
    String? title,
    String? subtitle,
    AppDialogType type = AppDialogType.info,
    Widget? icon,
    bool dismissible = true,
    bool showDefaultButtons = false,
    String confirmText = "OK",
    String cancelText = "Cancel",
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
    List<Widget>? actions,
    Widget? content,
    Color? backgroundColor,
    Color? titleColor,
    Color? subtitleColor,
    double borderRadius = 14,
    Duration transitionDuration = const Duration(milliseconds: 350),
    Curve curve = Curves.easeOutBack,
    Curve reverseCurve = Curves.easeInCubic,
    EdgeInsetsGeometry padding = const EdgeInsets.symmetric(
      horizontal: 20,
      vertical: 16,
    ),
    double? maxWidth,

    // Riverpod/Flutter:
    bool isLoading = false,
  }) {
    final (defaultIcon, typeColor) = _getDialogStyle(type);

    final defaultButtons = _buildDefaultButtons(
      context: context,
      typeColor: typeColor,
      confirmText: confirmText,
      cancelText: cancelText,
      onConfirm: onConfirm,
      onCancel: onCancel,
      isLoading: isLoading,
    );

    return showGeneralDialog(
      context: context,
      barrierDismissible: dismissible && !isLoading,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      transitionDuration: transitionDuration,
      pageBuilder: (context, animation, secondaryAnimation) =>
          const SizedBox.shrink(),
      transitionBuilder: (context, animation, secondaryAnimation, _) {
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: curve,
          reverseCurve: reverseCurve,
        );

        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: curvedAnimation,
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxWidth ?? 1.sw * 0.95),
                child: Dialog(
                  insetPadding: EdgeInsets.symmetric(
                    horizontal: 24.w,
                    vertical: 24.h,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(borderRadius),
                  ),
                  backgroundColor: backgroundColor ?? AppColors.white,
                  elevation: 10,
                  child: Padding(
                    padding: padding,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // ─────────────────────
                        // Icon
                        // ─────────────────────
                        if (icon != null || type != AppDialogType.custom)
                          _buildIcon(
                            icon: icon,
                            defaultIcon: defaultIcon,
                            typeColor: typeColor,
                          ),

                        // ─────────────────────
                        // Title
                        // ─────────────────────
                        if (title?.isNotEmpty ?? false)
                          Text(
                            title!,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: titleColor ?? AppColors.black,
                                ),
                          ),

                        // ─────────────────────
                        // Subtitle
                        // ─────────────────────
                        if (subtitle?.isNotEmpty ?? false)
                          Padding(
                            padding: const EdgeInsets.only(top: 8, bottom: 16),
                            child: Text(
                              subtitle!,
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    color:
                                        subtitleColor ??
                                        AppColors.grayTextSecondaryColor,
                                  ),
                            ),
                          ),

                        // ─────────────────────
                        // Content
                        // ─────────────────────
                        if (content != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 8, bottom: 16),
                            child: content,
                          ),

                        // ─────────────────────
                        // Actions
                        // ─────────────────────
                        if ((actions?.isNotEmpty ?? false) ||
                            showDefaultButtons)
                          _buildActionSection(
                            isLoading: isLoading,
                            actions: actions,
                            defaultButtons: defaultButtons,
                            loadingColor: typeColor,
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // ============================================================
  // Dialog Style
  // ============================================================

  static (IconData, Color) _getDialogStyle(AppDialogType type) {
    switch (type) {
      case AppDialogType.success:
        return (Icons.check_circle, Colors.green.shade600);

      case AppDialogType.error:
        return (Icons.error, Colors.red.shade600);

      case AppDialogType.warning:
        return (Icons.warning_amber_rounded, Colors.orange.shade700);

      case AppDialogType.info:
        return (Icons.info_outline, Colors.blue.shade600);

      case AppDialogType.custom:
        return (Icons.circle, AppColors.primaryColor);
    }
  }

  // ============================================================
  // Icon
  // ============================================================

  static Widget _buildIcon({
    required Widget? icon,
    required IconData defaultIcon,
    required Color typeColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: typeColor.withValues(alpha: 0.15),
      ),
      padding: const EdgeInsets.all(12),
      child: icon ?? Icon(defaultIcon, color: typeColor, size: 38),
    );
  }

  // ============================================================
  // Default Buttons
  // ============================================================

  static List<Widget> _buildDefaultButtons({
    required BuildContext context,
    required Color typeColor,
    required String confirmText,
    required String cancelText,
    required VoidCallback? onConfirm,
    required VoidCallback? onCancel,
    required bool isLoading,
  }) {
    final buttons = <Widget>[];

    if (onCancel != null) {
      buttons.add(
        Expanded(
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.grayTextSecondaryColor,
              side: BorderSide(
                color: AppColors.grayTextSecondaryColor.withValues(alpha: .3),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            onPressed: isLoading
                ? null
                : () {
                    Navigator.pop(context, false);

                    onCancel();
                  },
            child: Text(
              cancelText,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16.5),
            ),
          ),
        ),
      );

      buttons.add(const SizedBox(width: 12));
    }

    buttons.add(
      Expanded(
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: typeColor,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
          onPressed: isLoading
              ? null
              : () {
                  if (onConfirm != null) {
                    onConfirm();
                  } else {
                    Navigator.pop(context, true);
                  }
                },
          child: Text(
            confirmText,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16.5),
          ),
        ),
      ),
    );

    return buttons;
  }

  // ============================================================
  // Action Section
  // ============================================================

  static Widget _buildActionSection({
    required bool isLoading,
    required List<Widget>? actions,
    required List<Widget> defaultButtons,
    required Color loadingColor,
  }) {
    if (isLoading) {
      return SizedBox(
        height: 46,
        child: Center(child: CircularProgressIndicator(color: loadingColor)),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: actions ?? defaultButtons,
    );
  }
}
