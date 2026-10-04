import '../../parent_all/helper/parent_home_helper.dart';
import '../../share/export/screen_export.dart';

/// ===============================================================
/// STUDENT DETAILS SCREEN
/// ===============================================================

class TeacherStudentDetailsScreen extends StatelessWidget {
  const TeacherStudentDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.softBackground,
      appBar: AulaAppBar(
        title: 'Student Details',
        showBack: true,
        actions: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: const Color(0xfff0f3f8),
              borderRadius: BorderRadius.circular(4.r),
            ),
            child: Text(
              '#ST-2041',
              style: TxtStyle.bodyMedium(
                color: AppColors.subtitleTextColor,
                fontSize: 11.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(width: 10.w),
          Icon(
            Icons.more_vert_rounded,
            color: AppColors.subtitleTextColor,
            size: 20.sp,
          ),
          SizedBox(width: 4.w),
        ],
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 30.h),
        children: [
          _profileHeader(),
          SizedBox(height: 13.h),
          _metrics(),
          SizedBox(height: 18.h),
          _sectionTitle(
            'LATEST CLASS REPORT',
            trailing: 'Oct 24 · Session #18',
          ),
          SizedBox(height: 8.h),
          _latestReport(),
          SizedBox(height: 16.h),
          _sectionTitle('ACTIVE HOMEWORK', trailingWidget: _reviewDueTag()),
          SizedBox(height: 8.h),
          _homeworkCard(),
          SizedBox(height: 17.h),
          _sectionTitle('FACULTY NOTE', trailing: 'Dr. S. Jenkins'),
          SizedBox(height: 8.h),
          _facultyNote(),
          SizedBox(height: 8.h),
          _addNoteButton(),
        ],
      ),
    );
  }

  Widget _profileHeader() {
    return Row(
      children: [
        Stack(
          children: [
            Container(
              width: 52.w,
              height: 52.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xffdce5ef),
              ),
              child: Center(
                child: Text(
                  'LR',
                  style: TxtStyle.titleLarge(
                    color: AppColors.primaryDark,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            Positioned(
              right: 1,
              bottom: 1,
              child: Container(
                width: 10.w,
                height: 10.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xff18b86b),
                  border: Border.all(color: Colors.white, width: 1.5),
                ),
              ),
            ),
          ],
        ),
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
                      fontSize: 17.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(width: 6.w),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 7.w,
                      vertical: 3.h,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xffdef7e9),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Text(
                      'Active',
                      style: TxtStyle.bodyMedium(
                        color: const Color(0xff15965a),
                        fontSize: 10.5.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 4.h),
              Text(
                'Grade 11 • Group A • Calculus AB',
                style: TxtStyle.bodyMedium(
                  color: AppColors.subtitleTextColor,
                  fontSize: 12.sp,
                ),
              ),
              SizedBox(height: 3.h),
              Text(
                'Rm 204 • Desk 14    •    94% Attendance',
                style: TxtStyle.bodyMedium(
                  color: AppColors.subtitleTextColor,
                  fontSize: 12.sp,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _metrics() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(7.r),
        border: Border.all(color: AppColors.backgroundsLinesColor),
      ),
      child: Row(
        children: [
          _metric(value: '16/17', label: 'Present'),
          _metricDivider(),
          _metric(value: '92%', label: 'Mastery', highlighted: true),
          _metricDivider(),
          _metric(value: '8/9', label: 'Homework'),
        ],
      ),
    );
  }

  Widget _metric({
    required String value,
    required String label,
    bool highlighted = false,
  }) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: TxtStyle.titleLarge(
              color: highlighted ? AppColors.primaryDark : AppColors.text,
              fontSize: 17.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            label,
            style: TxtStyle.bodyMedium(
              color: AppColors.subtitleTextColor,
              fontSize: 12.5.sp,
            ),
          ),
        ],
      ),
    );
  }

  Widget _metricDivider() {
    return Container(
      width: 1,
      height: 30.h,
      color: AppColors.backgroundsLinesColor,
    );
  }

  Widget _sectionTitle(
    String title, {
    String? trailing,
    Widget? trailingWidget,
  }) {
    return Row(
      children: [
        Text(
          title,
          style: TxtStyle.titleLarge(
            color: AppColors.subtitleTextColor,
            fontSize: 13.sp,
            fontWeight: FontWeight.w700,
            letterSpacing: .45,
          ),
        ),
        const Spacer(),
        if (trailing != null)
          Text(
            trailing,
            style: TxtStyle.bodyMedium(
              color: AppColors.subtitleTextColor,
              fontSize: 12.5.sp,
            ),
          ),
        ?trailingWidget,
      ],
    );
  }

  Widget _latestReport() {
    return Container(
      padding: EdgeInsets.all(11.w),
      decoration: BoxDecoration(
        color: const Color(0xfff3f6fa),
        borderRadius: BorderRadius.circular(7.r),
        border: Border.all(color: AppColors.backgroundsLinesColor),
      ),
      child: RichText(
        text: TextSpan(
          style: TxtStyle.bodyMedium(
            color: AppColors.subtitleTextColor,
            fontSize: 12.5.sp,
            height: 1.45,
          ),
          children: [
            TextSpan(
              text: 'Blackboard Demo: ',
              style: TxtStyle.bodyMedium(
                color: AppColors.primaryDark,
                fontSize: 13.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
            const TextSpan(
              text:
                  'High effort. Mastered Chain Rule during blackboard demonstration with excellent attitude.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _reviewDueTag() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: const Color(0xffffe9c7),
        borderRadius: BorderRadius.circular(9.r),
      ),
      child: Text(
        'Review Due',
        style: TxtStyle.bodyMedium(
          color: const Color(0xffdf8a00),
          fontSize: 11.5.sp,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _homeworkCard() {
    return Container(
      padding: EdgeInsets.all(11.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(7.r),
        border: Border.all(color: AppColors.backgroundsLinesColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Problem Set 4: Implicit Differentiation',
            style: TxtStyle.titleLarge(
              color: AppColors.text,
              fontSize: 13.5.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            'Exercises 12–25 • Printed Binder Submission',
            style: TxtStyle.bodyMedium(
              color: AppColors.subtitleTextColor,
              fontSize: 13.sp,
            ),
          ),
          SizedBox(height: 9.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.calendar_today_outlined,
                    size: 11.sp,
                    color: AppColors.subtitleTextColor,
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    'Due Oct 29',
                    style: TxtStyle.bodyMedium(
                      color: AppColors.subtitleTextColor,
                      fontSize: 12.5.sp,
                    ),
                  ),
                ],
              ),
              Gap(10.w),
              Flexible(
                child: Text(
                  'Physical Copy in Hand',
                  style: TxtStyle.bodyMedium(
                    color: AppColors.primaryDark,
                    fontSize: 12.5.sp,
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

  Widget _facultyNote() {
    return Container(
      padding: EdgeInsets.all(11.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(7.r),
        border: Border.all(color: AppColors.backgroundsLinesColor),
      ),
      child: Text(
        '"Demonstrates strong conceptual grasp during board exercises. Actively assists peers in Group A during problem-solving sessions."',
        style: TxtStyle.bodyMedium(
          color: AppColors.subtitleTextColor,
          fontSize: 13.sp,
          height: 1.5,
          fontStyle: FontStyle.italic,
        ),
      ),
    );
  }

  Widget _addNoteButton() {
    return OutlinedButton(
      onPressed: () {},
      style: OutlinedButton.styleFrom(
        minimumSize: Size(double.infinity, 38.h),
        side: BorderSide(color: AppColors.backgroundsLinesColor),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7.r)),
      ),
      child: Text(
        '+ Add Note',
        style: TxtStyle.titleLarge(
          color: AppColors.primaryDark,
          fontSize: 14.sp,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
