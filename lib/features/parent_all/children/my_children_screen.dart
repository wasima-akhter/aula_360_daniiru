/// ===============================================================
/// 3. MY CHILDREN / MIS HIJOS
/// ===============================================================
library;

import '../../share/export/screen_export.dart';
import '../helper/parent_models.dart';
import '../helper/parent_widgets.dart';

class MyChildrenScreen extends ConsumerStatefulWidget {
  const MyChildrenScreen({super.key});

  @override
  ConsumerState<MyChildrenScreen> createState() => _MyChildrenScreenState();
}

class _MyChildrenScreenState extends ConsumerState<MyChildrenScreen> {
  final List<ChildModel> children = [lucasChild, sophiaChild];

  Future<void> _addChild() async {
    final result = await context.push(RoutePath.addChild);

    if (result is ChildModel) {
      setState(() {
        children.add(result);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F7FC),
      appBar: simpleAppBar(context, ref.watchTr(AppStrings.myChildren)),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.fromLTRB(14.w, 15.h, 14.w, 30.h),
          child: Column(
            children: [
              for (final child in children) ...[
                _childCard(child),
                SizedBox(height: 12.h),
              ],
              _addChildButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _childCard(ChildModel child) {
    return InkWell(
      onTap: () {
        context.push(RoutePath.childProfile, extra: child);
      },
      borderRadius: BorderRadius.circular(9.r),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(9.r),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            Row(
              children: [
                _childAvatar(child),
                SizedBox(width: 11.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        child.name,
                        style: TxtStyle.titleLarge(
                          color: AppColors.text,
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(height: 3.h),
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              '${child.grade} • ${child.room} • ',
                              overflow: TextOverflow.ellipsis,
                              style: TxtStyle.titleLarge(
                                color: AppColors.subtitleTextColor,
                                fontSize: 13.5.sp,
                              ),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 6.w,
                              vertical: 2.h,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.softSlateBgColor,
                              borderRadius: BorderRadius.circular(8.r),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Text(
                              child.id,
                              style: TxtStyle.titleLarge(
                                color: AppColors.subtitleTextColor,
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: AppColors.subtitleTextColor,
                  size: 20.sp,
                ),
              ],
            ),
            SizedBox(height: 9.h),
            Divider(height: 1, color: AppColors.backgroundsLinesColor),
            SizedBox(height: 9.h),
            Row(
              children: [
                Icon(
                  Icons.school_outlined,
                  color: AppColors.subtitleTextColor,
                  size: 14.sp,
                ),
                SizedBox(width: 6.w),
                Expanded(
                  child: Text(
                    child.parentTeacher,
                    style: TxtStyle.titleLarge(
                      color: AppColors.subtitleTextColor,
                      fontSize: 14.sp,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 9.h),
            Row(
              children: [
                Expanded(
                  child: _activeBadge(
                    '${child.attendance.toStringAsFixed(0)}% ${ref.watchTr(AppStrings.attendance)}',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _childAvatar(ChildModel child) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 49.w,
          height: 49.w,
          decoration: BoxDecoration(
            color: AppColors.blueSoft,
            borderRadius: BorderRadius.circular(7.r),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(7.r),
            child: Image.network(child.imageUrl, fit: BoxFit.cover),
          ),
        ),
        Positioned(
          right: -3.w,
          bottom: -2.h,
          child: Container(
            width: 12.w,
            height: 12.w,
            decoration: BoxDecoration(
              color: AppColors.emeraldGreenColor,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _activeBadge(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
        decoration: BoxDecoration(
          color: const Color(0xFFE1FAED),
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Text(
          '● ${ref.watchTr(AppStrings.active)} • $text',
          style: TxtStyle.titleLarge(
            color: AppColors.emeraldGreenColor,
            fontSize: 13.5.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Widget _addChildButton() {
    return InkWell(
      onTap: _addChild,
      borderRadius: BorderRadius.circular(8.r),
      child: Container(
        width: double.infinity,
        height: 45.h,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(
            color: AppColors.primary,
            style: BorderStyle.solid,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 22.w,
              height: 22.w,
              decoration: BoxDecoration(
                color: AppColors.blueSoft,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.add, color: AppColors.primaryDark, size: 16.sp),
            ),
            SizedBox(width: 8.w),
            Text(
              ref.watchTr(AppStrings.addAnotherChild),
              style: TxtStyle.titleLarge(
                color: AppColors.primaryDark,
                fontSize: 16.sp,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
