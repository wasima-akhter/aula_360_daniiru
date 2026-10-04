import '../../parent_all/helper/parent_home_helper.dart';
import '../../share/export/screen_export.dart';
import '../helper/teacher_models.dart';

/// ===============================================================
/// 2. CLASS DETAILS SCREEN
/// ===============================================================

class TeacherClassDetailScreen extends StatelessWidget {
  TeacherClassDetailScreen({super.key});

  final academyClass = todayClasses.first;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const AulaAppBar(title: 'Class Details', showBack: true),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(16.w, 19.h, 16.w, 35.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _groupLabel(),
                  SizedBox(height: 7.h),

                  Text(
                    'Advanced Mathematics\n(Calculus AB)',
                    style: TxtStyle.titleLarge(
                      color: AppColors.text,
                      fontSize: 27.sp,
                      height: 1.16,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -.4,
                    ),
                  ),

                  SizedBox(height: 17.h),

                  Divider(color: AppColors.backgroundsLinesColor, height: 1),

                  SizedBox(height: 17.h),

                  _detailsRow(
                    label: 'Time &\nDate',
                    value: 'Today, Oct 24 • 09:00 – 10:30 AM (90 mins)',
                  ),

                  _divider(),

                  _detailsRow(
                    label: 'Physical Classroom',
                    value: 'Room 204, Hall A (Building B)',
                  ),

                  _divider(),

                  _detailsRow(label: 'Enrolled', value: '18 Students Enrolled'),

                  SizedBox(height: 23.h),

                  Divider(color: AppColors.backgroundsLinesColor, height: 1),

                  SizedBox(height: 18.h),

                  Text(
                    'PHYSICAL SESSION INFO',
                    style: TxtStyle.titleLarge(
                      color: AppColors.subtitleTextColor,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w800,
                      letterSpacing: .6,
                    ),
                  ),

                  SizedBox(height: 10.h),

                  _infoCard(
                    title: "Today's Topic",
                    value: 'Chain Rule & Implicit Differentiation',
                  ),

                  SizedBox(height: 10.h),

                  _roomStatusCard(),

                  SizedBox(height: 34.h),

                  SizedBox(
                    width: double.infinity,

                    child: AulaPrimaryButton(
                      onTap: () {
                        context.push(RoutePath.teacherAttendance);
                      },
                      text: 'Start Class & Take Attendance',
                      trailing: Icon(
                        Icons.arrow_forward_rounded,
                        color: Colors.white,
                        size: 18.sp,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _groupLabel() {
    return Text(
      'GROUP A • GRADE 11',
      style: TxtStyle.titleLarge(
        color: AppColors.tealTextColor,
        fontSize: 15.5.sp,
        fontWeight: FontWeight.w600,
        letterSpacing: .5,
      ),
    );
  }

  Widget _detailsRow({required String label, required String value}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 105.w,
            child: Text(
              label,
              style: TxtStyle.bodyMedium(
                color: AppColors.subtitleTextColor,
                fontSize: 16.sp,
                height: 1.35,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TxtStyle.labelLarge(
                color: AppColors.text,
                fontSize: 16.sp,
                height: 1.35,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() {
    return Container(height: 1, color: AppColors.backgroundsLinesColor);
  }

  Widget _infoCard({required String title, required String value}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(12.w, 12.h, 12.w, 12.h),
      decoration: BoxDecoration(
        color: AppColors.softSlateBgColor,
        borderRadius: BorderRadius.circular(7.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TxtStyle.titleLarge(
              color: AppColors.subtitleTextColor,
              fontSize: 14.sp,
            ),
          ),
          SizedBox(height: 5.h),
          Text(
            value,
            style: TxtStyle.titleLarge(
              color: AppColors.text,
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _roomStatusCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(12.w, 12.h, 12.w, 13.h),
      decoration: BoxDecoration(
        color: AppColors.softSlateBgColor,
        borderRadius: BorderRadius.circular(7.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Physical Room Status',
            style: TxtStyle.titleLarge(
              color: AppColors.subtitleTextColor,
              fontSize: 14.sp,
            ),
          ),
          SizedBox(height: 6.h),
          Row(
            children: [
              Container(
                width: 7.w,
                height: 7.w,
                decoration: const BoxDecoration(
                  color: AppColors.emeraldGreenColor,
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: 7.w),
              Expanded(
                child: Text(
                  'Board & desks prepared • Turnstiles active',
                  style: TxtStyle.titleLarge(
                    color: AppColors.text,
                    fontSize: 15.5.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
