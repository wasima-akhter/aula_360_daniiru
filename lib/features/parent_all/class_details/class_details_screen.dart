import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../share/export/screen_export.dart';
import '../helper/parent_home_helper.dart';

class ClassDetailsScreen extends ConsumerStatefulWidget {
  final ClassModel classData;

  const ClassDetailsScreen({super.key, required this.classData});

  @override
  ConsumerState<ClassDetailsScreen> createState() => _ClassDetailsScreenState();
}

class _ClassDetailsScreenState extends ConsumerState<ClassDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    final data = widget.classData;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F7FC),
      appBar: AulaAppBar(
        title: ref.watchTr(AppStrings.classDetailsTitle),
        showBack: true,
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(
              Icons.more_vert_rounded,
              color: AppColors.text,
              size: 23.sp,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: EdgeInsets.fromLTRB(16.w, 18.h, 16.w, 30.h),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // =================================================
                  // STUDENT
                  // =================================================
                  AulaCard(
                    child: Row(
                      children: [
                        const UserAvatar(initials: 'LR', size: 42),
                        SizedBox(width: 11.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    'Lucas Rivera',
                                    style: TxtStyle.titleLarge(
                                      color: AppColors.text,
                                      fontSize: 18.sp,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  SizedBox(width: 7.w),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 6.w,
                                      vertical: 3.h,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFE8EDFF),
                                      borderRadius: BorderRadius.circular(5.r),
                                    ),
                                    child: Text(
                                      ref.watchTr(AppStrings.eso2),
                                      style: TxtStyle.titleLarge(
                                        color: AppColors.primary,
                                        fontSize: 13.5.sp,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                '${ref.watchTr(AppStrings.aula3)} • ID #A360-842',
                                style: TxtStyle.titleLarge(
                                  color: AppColors.secondaryText,
                                  fontSize: 14.5.sp,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 13.h),

                  // =================================================
                  // CLASS NAME
                  // =================================================
                  AulaCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          data.subject,
                          style: TxtStyle.titleLarge(
                            color: AppColors.primary,
                            fontSize: 23.sp,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        SizedBox(height: 7.h),
                        Text(
                          _descriptionFor(data.category),
                          style: TxtStyle.titleLarge(
                            color: AppColors.secondaryText,
                            fontSize: 15.sp,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 14.h),

                  // =================================================
                  // SCHEDULE & TIMING
                  // =================================================
                  AulaCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _smallTitle(ref.watchTr(AppStrings.scheduleAndTiming)),
                        SizedBox(height: 12.h),
                        _detailRow(
                          icon: Icons.calendar_today_outlined,
                          label: ref.watchTr(AppStrings.date),
                          value: 'Miércoles, 24 de Octubre de 2024',
                        ),
                        SizedBox(height: 10.h),
                        _detailRow(
                          icon: Icons.access_time_rounded,
                          label: ref.watchTr(AppStrings.timeSlot),
                          value: '${data.time} – ${data.duration}',
                          trailing: '90 min',
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 14.h),

                  // =================================================
                  // LOCATION
                  // =================================================
                  AulaCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            _smallTitle(ref.watchTr(AppStrings.academyLocation)),
                            const Spacer(),
                            Icon(
                              Icons.business_outlined,
                              size: 14.sp,
                              color: AppColors.primary,
                            ),
                            SizedBox(width: 4.w),
                            Flexible(
                              child: Text(
                                ref.watchTr(AppStrings.mockMainBuilding),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TxtStyle.titleLarge(
                                  color: AppColors.primary,
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 12.h),
                        Text(
                          '${data.room}, ${data.building}',
                          style: TxtStyle.titleLarge(
                            color: AppColors.text,
                            fontSize: 17.sp,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          ref.watchTr(AppStrings.mockBuildingFloor),
                          style: TxtStyle.titleLarge(
                            color: AppColors.secondaryText,
                            fontSize: 14.sp,
                          ),
                        ),
                        SizedBox(height: 12.h),
                        Container(
                          height: 150.h,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE5E7E9),
                            borderRadius: BorderRadius.circular(9.r),
                          ),
                          child: Stack(
                            children: [
                              Center(
                                child: Icon(
                                  Icons.map_outlined,
                                  size: 50.sp,
                                  color: Colors.grey.shade400,
                                ),
                              ),
                              Positioned(
                                left: 12.w,
                                bottom: 10.h,
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 9.w,
                                    vertical: 6.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: .45),
                                    borderRadius: BorderRadius.circular(6.r),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.location_on_rounded,
                                        color: Colors.white,
                                        size: 14,
                                      ),
                                      SizedBox(width: 4.w),
                                      Text(
                                        '${ref.watchTr(AppStrings.mockFloorPlanOf)} ${data.room}',
                                        style: TxtStyle.titleLarge(
                                          color: Colors.white,
                                          fontSize: 14.sp,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Positioned(
                                right: 10.w,
                                bottom: 10.h,
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 9.w,
                                    vertical: 6.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(6.r),
                                  ),
                                  child: Text(
                                    ref.watchTr(AppStrings.viewFloorPlan),
                                    style: TxtStyle.titleLarge(
                                      color: AppColors.primary,
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 14.h),

                  // =================================================
                  // INSTRUCTOR
                  // =================================================
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      context.push(RoutePath.teacherInformation);
                    },
                    child: AulaCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _smallTitle(ref.watchTr(AppStrings.teacherInfoTitle)),
                              const Icon(Icons.chevron_right),
                            ],
                          ),
                          SizedBox(height: 13.h),
                          Row(
                            children: [
                              UserAvatar(
                                initials: _teacherInitials(data.teacher),
                                size: 43,
                              ),
                              SizedBox(width: 10.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      data.teacher,
                                      style: TxtStyle.titleLarge(
                                        color: AppColors.text,
                                        fontSize: 17.sp,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    SizedBox(height: 3.h),
                                    Text(
                                      '${ref.watchTr(AppStrings.teacherOfPrefix)} ${data.category}',
                                      style: TxtStyle.bodyMedium(
                                        color: AppColors.secondaryText,
                                        fontSize: 14.sp,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 13.h),
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(11.w),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8F6FD),
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.access_time_rounded,
                                  size: 16.sp,
                                  color: AppColors.primary,
                                ),
                                SizedBox(width: 7.w),
                                Expanded(
                                  child: Text(
                                    ref.watchTr(AppStrings.mockOfficeHours),
                                    style: TxtStyle.titleLarge(
                                      color: AppColors.secondaryText,
                                      fontSize: 14.sp,
                                      height: 1.4,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _smallTitle(String text) {
    return Text(
      text,
      style: TxtStyle.titleLarge(
        color: AppColors.secondaryText,
        fontSize: 14.sp,
        fontWeight: FontWeight.w700,
        letterSpacing: .45,
      ),
    );
  }

  Widget _detailRow({
    required IconData icon,
    required String label,
    required String value,
    String? trailing,
  }) {
    return Container(
      padding: EdgeInsets.all(11.w),
      decoration: BoxDecoration(
        color: const Color(0xFFFAF8FE),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        children: [
          Container(
            width: 30.w,
            height: 30.w,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(7.r),
            ),
            child: Icon(icon, color: AppColors.primary, size: 17.sp),
          ),
          SizedBox(width: 9.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TxtStyle.titleLarge(
                    color: AppColors.secondaryText,
                    fontSize: 13.5.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 3.h),
                Text(
                  value,
                  style: TxtStyle.titleLarge(
                    color: AppColors.text,
                    fontSize: 14.5.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          if (trailing != null)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: const Color(0xFFE9EDFF),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Text(
                trailing,
                style: TxtStyle.titleLarge(
                  color: AppColors.primary,
                  fontSize: 13.5.sp,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _teacherInitials(String name) {
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}';
    }
    return name.substring(0, 2).toUpperCase();
  }

  String _descriptionFor(String category) {
    switch (category) {
      case 'Física':
      case 'Physics':
        return ref.watchTr(AppStrings.mockPhysicsDesc);
      case 'Lengua':
      case 'English':
      case 'Spanish':
        return ref.watchTr(AppStrings.mockLanguageDesc);
      default:
        return ref.watchTr(AppStrings.mockMathDesc);
    }
  }
}
