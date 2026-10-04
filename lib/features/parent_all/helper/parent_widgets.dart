/// ===============================================================
/// COMMON APP BAR
/// ===============================================================
library;

import '../../share/export/screen_export.dart';

PreferredSizeWidget simpleAppBar(
  BuildContext context,
  String title, {
  bool showBackButton = true,
}) {
  return AppBar(
    backgroundColor: Colors.white,
    elevation: 0,
    centerTitle: true,
    leading: showBackButton
        ? IconButton(
            onPressed: () => context.pop(),
            icon: Icon(
              Icons.arrow_back,
              color: AppColors.primaryDark,
              size: 22.sp,
            ),
          )
        : null,
    title: Text(
      title,
      style: TxtStyle.titleLarge(
        color: AppColors.primaryDark,
        fontSize: 18.sp,
        fontWeight: FontWeight.w800,
      ),
    ),
    bottom: PreferredSize(
      preferredSize: Size.fromHeight(1.h),
      child: Container(height: 1, color: AppColors.backgroundsLinesColor),
    ),
  );
}
