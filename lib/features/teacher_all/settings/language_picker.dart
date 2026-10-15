import '../../share/export/screen_export.dart';
import '../../settings/presentation/providers/settings_providers.dart';

/// Bottom-sheet language picker.
/// Shows only English (US) and Spanish (no English UK).
/// Selecting a language immediately updates the central [languageProvider] and backend settings.
class LanguagePicker extends ConsumerWidget {
  const LanguagePicker({super.key, required this.selectedLanguage});

  final String selectedLanguage;

  static Future<void> show({
    required BuildContext context,
    required String selectedLanguage,
    required WidgetRef ref,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      showDragHandle: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18.r)),
      ),
      builder: (_) {
        return LanguagePicker(selectedLanguage: selectedLanguage);
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final langAsync = ref.watch(languageProvider);
    final tr = ref.watchTr;

    final languages = [AppLanguage.english, AppLanguage.spanish];

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(bottom: 15.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 5.h),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  tr(AppStrings.languagePickerTitle),
                  style: TxtStyle.titleLarge(
                    color: AppColors.text,
                    fontSize: 19.sp,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),

            ...languages.map((lang) {
              final isSelected = langAsync.valueOrNull?.language == lang;
              return InkWell(
                onTap: () async {
                  await ref
                      .read(languageProvider.notifier)
                      .changeLanguage(lang);
                  try {
                    final backendLang =
                        lang == AppLanguage.spanish ? 'ES' : 'EN';
                    await ref
                        .read(updateLanguageUseCaseProvider)
                        .call(backendLang);
                  } catch (_) {}
                  if (context.mounted) Navigator.pop(context);
                },
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 18.w,
                    vertical: 12.h,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 20.w,
                        height: 20.w,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.secondaryText,
                            width: isSelected ? 6.w : 1.5.w,
                          ),
                        ),
                      ),
                      SizedBox(width: 14.w),
                      Expanded(
                        child: Text(
                          lang == AppLanguage.english
                              ? tr(AppStrings.languageEnglishUs)
                              : tr(AppStrings.languageSpanishLabel),
                          style: TxtStyle.titleLarge(
                            fontSize: 16.sp,
                            fontWeight: isSelected
                                ? FontWeight.w700
                                : FontWeight.w500,
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.text,
                          ),
                        ),
                      ),
                      if (isSelected)
                        Icon(
                          Icons.check_rounded,
                          color: AppColors.primary,
                          size: 20.sp,
                        ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
