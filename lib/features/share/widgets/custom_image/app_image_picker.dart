import 'dart:io';

import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../../export/screen_export.dart';

enum ImagePickerSource { camera, gallery }

enum _PickerAction { preview, gallery, camera, remove }

class AppImagePicker {
  AppImagePicker._();

  static final ImagePicker _picker = ImagePicker();

  /// Centrally shows the bottom sheet modal with Camera, Gallery, and optional Preview / Remove options.
  /// Handles permission errors gracefully with user-friendly messages.
  static Future<File?> showImagePickerBottomSheet(
    BuildContext context, {
    required WidgetRef ref,
    String? title,
    String? subtitle,
    bool showRemoveOption = false,
    VoidCallback? onRemovePhoto,
    bool showPreviewOption = false,
    VoidCallback? onPreviewPhoto,
    double? maxWidth = 1200,
    double? maxHeight = 1200,
    int? imageQuality = 85,
  }) async {
    final action = await showModalBottomSheet<_PickerAction>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (bottomSheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  title ?? ref.watchTr(AppStrings.chooseProfilePhoto),
                  style: context.titleMedium.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.text,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle ?? ref.watchTr(AppStrings.selectOptionProfilePhoto),
                  textAlign: TextAlign.center,
                  style: context.bodySmall.copyWith(
                    color: AppColors.secondaryText,
                  ),
                ),
                const SizedBox(height: 16),
                if (showPreviewOption && onPreviewPhoto != null) ...[
                  ImagePickerOption(
                    icon: Icons.visibility_outlined,
                    title: ref.watchTr(AppStrings.viewProfilePhoto),
                    onTap: () {
                      Navigator.pop(bottomSheetContext, _PickerAction.preview);
                    },
                  ),
                  const SizedBox(height: 10),
                ],
                ImagePickerOption(
                  icon: Icons.photo_library_outlined,
                  title: ref.watchTr(AppStrings.chooseFromGallery),
                  onTap: () {
                    Navigator.pop(bottomSheetContext, _PickerAction.gallery);
                  },
                ),
                const SizedBox(height: 10),
                ImagePickerOption(
                  icon: Icons.camera_alt_outlined,
                  title: ref.watchTr(AppStrings.takeAPhoto),
                  onTap: () {
                    Navigator.pop(bottomSheetContext, _PickerAction.camera);
                  },
                ),
                if (showRemoveOption && onRemovePhoto != null) ...[
                  const SizedBox(height: 10),
                  ImagePickerOption(
                    icon: Icons.delete_outline_rounded,
                    title: ref.watchTr(AppStrings.removePhoto),
                    iconColor: AppColors.error,
                    textColor: AppColors.error,
                    onTap: () {
                      Navigator.pop(bottomSheetContext, _PickerAction.remove);
                    },
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );

    if (action == null || !context.mounted) return null;

    if (action == _PickerAction.preview) {
      onPreviewPhoto?.call();
      return null;
    }

    if (action == _PickerAction.remove) {
      onRemovePhoto?.call();
      return null;
    }

    final source = action == _PickerAction.camera
        ? ImagePickerSource.camera
        : ImagePickerSource.gallery;

    return pickImage(
      source: source,
      context: context,
      ref: ref,
      maxWidth: maxWidth,
      maxHeight: maxHeight,
      imageQuality: imageQuality,
    );
  }

  static Future<File?> pickImage({
    required ImagePickerSource source,
    BuildContext? context,
    WidgetRef? ref,
    double? maxWidth,
    double? maxHeight,
    int? imageQuality,
  }) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: _getImageSource(source),
        maxWidth: maxWidth,
        maxHeight: maxHeight,
        imageQuality: imageQuality,
      );

      return pickedFile != null ? File(pickedFile.path) : null;
    } on PlatformException catch (e) {
      if (context != null && context.mounted) {
        final isCamera = source == ImagePickerSource.camera;
        final isDenied = e.code.toLowerCase().contains('denied') ||
            (e.message?.toLowerCase().contains('permission') ?? false) ||
            (e.message?.toLowerCase().contains('access') ?? false);

        if (isDenied) {
          final lang = ref?.read(languageProvider).valueOrNull;
          final title = lang?.tr(AppStrings.validationError) ?? 'Permission Required';
          final message = isCamera
              ? (lang?.tr(AppStrings.cameraPermissionRequired) ??
                  'Camera permission is required to take a photo. Please allow camera access in Settings.')
              : (lang?.tr(AppStrings.photosPermissionRequired) ??
                  'Photos permission is required to select an image. Please allow photo access in Settings.');

          ApiSnackbar.showUserMessage(
            UserFriendlyMessage(title: title, message: message),
            type: SnackbarType.warning,
          );
        }
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  static Future<File?> pickFromGallery({
    BuildContext? context,
    WidgetRef? ref,
    double? maxWidth,
    double? maxHeight,
    int imageQuality = 85,
  }) {
    return pickImage(
      source: ImagePickerSource.gallery,
      context: context,
      ref: ref,
      maxWidth: maxWidth,
      maxHeight: maxHeight,
      imageQuality: imageQuality,
    );
  }

  static Future<File?> takeFromCamera({
    BuildContext? context,
    WidgetRef? ref,
    double? maxWidth,
    double? maxHeight,
    int imageQuality = 85,
  }) {
    return pickImage(
      source: ImagePickerSource.camera,
      context: context,
      ref: ref,
      maxWidth: maxWidth,
      maxHeight: maxHeight,
      imageQuality: imageQuality,
    );
  }

  static ImageSource _getImageSource(ImagePickerSource source) {
    switch (source) {
      case ImagePickerSource.camera:
        return ImageSource.camera;
      case ImagePickerSource.gallery:
        return ImageSource.gallery;
    }
  }
}

class ImagePickerOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Color? iconColor;
  final Color? textColor;

  const ImagePickerOption({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
    this.iconColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveIconColor = iconColor ?? AppColors.primary;
    final effectiveTextColor = textColor ?? AppColors.text;

    return Material(
      color: const Color(0xFFF7F8FA),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: effectiveIconColor.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: effectiveIconColor, size: 21),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  title,
                  style: context.bodyMedium.copyWith(
                    color: effectiveTextColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: AppColors.secondaryText,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
