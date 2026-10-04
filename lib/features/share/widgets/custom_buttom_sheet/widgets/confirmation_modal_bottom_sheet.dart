import 'package:aula360/features/share/export/screen_export.dart';

import '../../../../../core/custom_assets/assets.gen.dart';
import '../custom_buttom_sheet.dart';

class ConfirmationModalBottomSheet extends StatelessWidget {
  final String title;
  final String message;
  final String confirmButtonText;
  final VoidCallback onConfirm;

  const ConfirmationModalBottomSheet({
    super.key,
    required this.title,
    required this.message,
    required this.confirmButtonText,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final primaryTextColor = isDarkMode
        ? AppColors.white
        : AppColors.blackMainTextColor;

    return makeDismissable(
      context,
      child: DraggableScrollableSheet(
        initialChildSize: 0.40,
        minChildSize: 0.25,
        maxChildSize: 0.4,
        expand: false,
        builder: (_, controller) => Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: BorderRadius.vertical(top: Radius.circular(30.r)),
          ),
          child: SingleChildScrollView(
            controller: controller,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 32.h),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Center(child: Assets.icons.successfullIcon.svg()),
                  Gap(24.h),
                  Text(
                    title,
                    style: TxtStyle.titleLarge(
                      fontWeight: FontWeight.w800,
                      fontSize: 25.5.sp,
                      color: primaryTextColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  Gap(12.h),
                  Text(
                    message,
                    style: TxtStyle.titleLarge(
                      fontSize: 16.5.sp,
                      color: AppColors.grayTextSecondaryColor,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  Gap(36.h),
                  Row(
                    children: [
                      Expanded(
                        child: CustomButton(
                          text: AppStrings.back,
                          onTap: () => AppRouter.router.pop(),
                        ),
                      ),
                      Gap(16.w),
                      Expanded(
                        child: CustomButton(
                          text: confirmButtonText,
                          onTap: () {
                            onConfirm();
                            AppRouter.router.pop();
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
