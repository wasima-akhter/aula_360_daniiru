import 'dart:io';

import 'package:image_picker/image_picker.dart';

import '../../export/screen_export.dart';

enum ImagePickerSource { camera, gallery }

class AppImagePicker {
  AppImagePicker._();

  static final ImagePicker _picker = ImagePicker();

  static Future<File?> pickImage({
    required ImagePickerSource source,
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
    } catch (_) {
      return null;
    }
  }

  static Future<File?> pickFromGallery({
    double? maxWidth,
    double? maxHeight,
    int imageQuality = 85,
  }) {
    return pickImage(
      source: ImagePickerSource.gallery,
      maxWidth: maxWidth,
      maxHeight: maxHeight,
      imageQuality: imageQuality,
    );
  }

  static Future<File?> takeFromCamera({
    double? maxWidth,
    double? maxHeight,
    int imageQuality = 85,
  }) {
    return pickImage(
      source: ImagePickerSource.camera,
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
  const ImagePickerOption({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) {
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
                  color: AppColors.primary.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: AppColors.primary, size: 21),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  title,
                  style: context.bodyMedium.copyWith(
                    color: AppColors.text,
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
