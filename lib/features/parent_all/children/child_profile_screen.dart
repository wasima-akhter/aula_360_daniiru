import '../../share/export/screen_export.dart';
import '../helper/parent_models.dart';
import '../helper/parent_widgets.dart';

/// ===============================================================
/// 5. CHILD PROFILE
/// ===============================================================

class ChildProfileScreen extends StatelessWidget {
  const ChildProfileScreen({super.key});
  final child = sophiaChild;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F7FC),
      appBar: simpleAppBar(context, 'Child Profile'),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.fromLTRB(14.w, 14.h, 14.w, 30.h),
          child: Column(
            children: [
              _studentHeader(context),
              SizedBox(height: 18.h),
              _sectionLabel('ACADEMIC ACTIVITY'),
              SizedBox(height: 8.h),
              _activityCard(context),
              SizedBox(height: 13.h),
              _messageCard(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _studentHeader(BuildContext context) {
    return Container(
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
              Container(
                width: 51.w,
                height: 51.w,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.r),
                  color: AppColors.blueSoft,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.r),
                  child: Image.network(child.imageUrl, fit: BoxFit.cover),
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      child.name,
                      style: TxtStyle.titleLarge(
                        color: AppColors.text,
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 3.h),
                    Text(
                      '${child.grade} • ${child.room} • ID: ${child.id}',
                      style: TxtStyle.titleLarge(
                        color: AppColors.subtitleTextColor,
                        fontSize: 15.sp,
                      ),
                    ),
                    SizedBox(height: 3.h),
                    Row(
                      children: [
                        Icon(
                          Icons.school_outlined,
                          size: 17.sp,
                          color: AppColors.primaryDark,
                        ),
                        SizedBox(width: 3.w),
                        Text(
                          'St. Matthew Preparatory',
                          style: TxtStyle.titleLarge(
                            color: AppColors.subtitleTextColor,
                            fontSize: 15.sp,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 11.h),
          Divider(height: 1, color: AppColors.backgroundsLinesColor),
          SizedBox(height: 11.h),
          Row(
            children: [
              Expanded(
                child: _stat(
                  'Attendance',
                  '${child.attendance.toStringAsFixed(1)}%',
                  AppColors.emeraldGreenColor,
                ),
              ),
              Expanded(child: _stat('Term GPA', '3.8', AppColors.primaryDark)),
              Expanded(
                child: _stat('Homework', '2 Due', AppColors.orangeColor),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _stat(String title, String value, Color color) {
    return Column(
      children: [
        Text(
          title,
          style: TxtStyle.titleLarge(
            color: AppColors.subtitleTextColor,
            fontSize: 15.sp,
          ),
        ),
        SizedBox(height: 3.h),
        Text(
          value,
          style: TxtStyle.titleLarge(
            color: color,
            fontSize: 18.sp,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }

  Widget _sectionLabel(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: TxtStyle.titleLarge(
          color: AppColors.text,
          fontSize: 17.sp,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _activityCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(9.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          _activityRow(
            icon: Icons.calendar_month_outlined,
            color: AppColors.primaryDark,
            title: 'Schedule',
            subtitle: "Today's Classes & Timetable",
            onTap: () {},
          ),
          _divider(),
          _activityRow(
            icon: Icons.fact_check_outlined,
            color: AppColors.emeraldGreenColor,
            title: 'Attendance',
            subtitle:
                '${child.attendance.toStringAsFixed(0)}% attendance record',
            onTap: () {
              context.push(RoutePath.attendance, extra: child);
            },
          ),
          _divider(),
          _activityRow(
            icon: Icons.description_outlined,
            color: AppColors.primaryDark,
            title: 'Reports',
            subtitle: 'Post-class reviews & summaries',
            onTap: () {},
          ),
          _divider(),
          _activityRow(
            icon: Icons.assignment_outlined,
            color: AppColors.orangeColor,
            title: 'Homework',
            subtitle: '2 Assignments pending',
            onTap: () {},
          ),
          _divider(),
          _activityRow(
            icon: Icons.trending_up,
            color: AppColors.purpleAccentColor,
            title: 'Academic Progress',
            subtitle: 'Grades, scores & term evaluation',
            onTap: () {},
          ),
          _divider(),
          _activityRow(
            icon: Icons.school_outlined,
            color: AppColors.subtitleTextColor,
            title: 'Teacher Information',
            subtitle: 'Ms. Sarah Vance & faculty info',
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _activityRow({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 11.h),
        child: Row(
          children: [
            Container(
              width: 31.w,
              height: 31.w,
              decoration: BoxDecoration(
                color: color.withValues(alpha: .10),
                borderRadius: BorderRadius.circular(7.r),
              ),
              child: Icon(icon, color: color, size: 19.sp),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TxtStyle.titleLarge(
                      color: AppColors.text,
                      fontSize: 17.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    subtitle,
                    style: TxtStyle.bodyMedium(
                      color: AppColors.subtitleTextColor,
                      fontSize: 15.sp,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: AppColors.subtitleTextColor,
              size: 19.sp,
            ),
          ],
        ),
      ),
    );
  }

  Widget _messageCard() {
    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(8.r),
      child: Container(
        padding: EdgeInsets.all(11.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 32.w,
              height: 32.w,
              decoration: BoxDecoration(
                color: AppColors.blueSoft,
                borderRadius: BorderRadius.circular(7.r),
              ),
              child: Icon(
                Icons.chat_bubble_outline,
                color: AppColors.primaryDark,
                size: 18.sp,
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Message Academy',
                    style: TxtStyle.titleLarge(
                      color: AppColors.text,
                      fontSize: 17.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    'Contact homeroom or office',
                    style: TxtStyle.bodyMedium(
                      color: AppColors.subtitleTextColor,
                      fontSize: 15.sp,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 5.h),
              decoration: BoxDecoration(
                color: AppColors.blueSoft,
                borderRadius: BorderRadius.circular(6.r),
              ),
              child: Text(
                'Contact',
                style: TxtStyle.titleLarge(
                  color: AppColors.primaryDark,
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _divider() {
    return Container(height: 1, color: AppColors.backgroundsLinesColor);
  }
}
