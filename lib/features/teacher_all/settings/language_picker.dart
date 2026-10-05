import '../../share/export/screen_export.dart';

/// Bottom-sheet language picker.
/// Shows only English (US) and Spanish (no English UK).
/// Selecting a language immediately updates the central [languageProvider].
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

            ...languages.map(
              (lang) => RadioListTile<AppLanguage>(
                value: lang,
                groupValue: langAsync.valueOrNull?.language,
                activeColor: AppColors.primary,
                title: Text(
                  lang == AppLanguage.english
                      ? tr(AppStrings.languageEnglishUs)
                      : tr(AppStrings.languageSpanishLabel),
                  style: TxtStyle.titleLarge(fontSize: 16.sp),
                ),
                onChanged: (value) async {
                  if (value != null) {
                    await ref
                        .read(languageProvider.notifier)
                        .changeLanguage(value);
                    if (context.mounted) Navigator.pop(context);
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
