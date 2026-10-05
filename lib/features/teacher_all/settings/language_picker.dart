import '../../share/export/screen_export.dart';

class LanguagePicker extends StatelessWidget {
  const LanguagePicker({super.key, required this.selectedLanguage});

  final String selectedLanguage;

  static Future<String?> show({
    required BuildContext context,
    required String selectedLanguage,
  }) {
    return showModalBottomSheet<String>(
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
  Widget build(BuildContext context) {
    final languages = ['English (US)', 'English (UK)', 'Spanish'];

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
                  'Select Language',
                  style: TxtStyle.titleLarge(
                    color: AppColors.text,
                    fontSize: 19.sp,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),

            ...languages.map(
              (language) => RadioListTile<String>(
                value: language,
                groupValue: selectedLanguage,
                activeColor: AppColors.primary,
                title: Text(
                  language,
                  style: TxtStyle.titleLarge(fontSize: 16.sp),
                ),
                onChanged: (value) {
                  if (value != null) {
                    Navigator.pop(context, value);
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
