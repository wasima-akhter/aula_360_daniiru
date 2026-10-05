import '../../parent_all/helper/parent_home_helper.dart';
import '../../share/export/screen_export.dart';

/// ===============================================================
/// REPORT DETAILS SCREEN
/// ===============================================================

class TeacherReportDetailsScreen extends StatelessWidget {
  const TeacherReportDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.softBackground,
      appBar: AulaAppBar(
        title: 'Report Details',
        showBack: true,
        actions: [
          Icon(
            Icons.share_outlined,
            color: AppColors.subtitleTextColor,
            size: 19.sp,
          ),
          SizedBox(width: 14.w),
        ],
      ),
      body: SafeArea(
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 30.h),
          children: [
            _recordHeader(),
            SizedBox(height: 17.h),
            _attendanceSection(),
            SizedBox(height: 17.h),
            _contentSection(),
            SizedBox(height: 17.h),
            _homeworkSection(),
            SizedBox(height: 17.h),
            _facultyObservation(),
            SizedBox(height: 19.h),
            _downloadButton(),
          ],
        ),
      ),
    );
  }

  Widget _recordHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'PHYSICAL RECORD • #AR-8041',
          style: TxtStyle.titleLarge(
            color: AppColors.subtitleTextColor,
            fontSize: 15.sp,
            fontWeight: FontWeight.w700,
            letterSpacing: .5,
          ),
        ),
        SizedBox(height: 7.h),
        Text(
          'Advanced Mathematics (Calculus AB)',
          style: TxtStyle.titleLarge(
            color: AppColors.text,
            fontSize: 22.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: 5.h),
        Text(
          'Group A  •  Room 204  •  Oct 24, 2024',
          style: TxtStyle.bodyMedium(
            color: AppColors.subtitleTextColor,
            fontSize: 15.sp,
          ),
        ),
        SizedBox(height: 5.h),
        RichText(
          text: TextSpan(
            style: TxtStyle.bodyMedium(
              color: AppColors.subtitleTextColor,
              fontSize: 15.sp,
            ),
            children: [
              const TextSpan(text: 'Teacher: '),
              TextSpan(
                text: 'Dr. Sarah Jenkins',
                style: TxtStyle.bodyMedium(
                  color: AppColors.text,
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _attendanceSection() {
    return _detailSection(
      title: 'ATTENDANCE & PARTICIPATION',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '18 of 18 Present (100%)',
            style: TxtStyle.titleLarge(
              color: AppColors.text,
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 5.h),
          Text(
            'Attitude rating: 5.0 / 5.0 • Work rigor: 4.8 / 5.0',
            style: TxtStyle.bodyMedium(
              color: AppColors.subtitleTextColor,
              fontSize: 16.sp,
            ),
          ),
        ],
      ),
    );
  }

  Widget _contentSection() {
    return _detailSection(
      title: 'CONTENT COVERED',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Unit 4: Chain Rule & Implicit Differentiation',
            style: TxtStyle.titleLarge(
              color: AppColors.text,
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            'Conducted chalkboard derivations for composite trigonometric functions. '
            'All 18 students completed 4 whiteboard drill problems in pairs, '
            'followed by textbook exercises 14–28 from Section 4.2.',
            style: TxtStyle.bodyMedium(
              color: AppColors.subtitleTextColor,
              fontSize: 16.sp,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _homeworkSection() {
    return _detailSection(
      title: 'ASSIGNED HOMEWORK',
      trailing: 'Due Oct 29',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Problem Set 4: Implicit Differentiation & Composite Functions',
            style: TxtStyle.titleLarge(
              color: AppColors.text,
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            'Exercises 12–25 on workbook pages 88–91 with complete written proofs.',
            style: TxtStyle.bodyMedium(
              color: AppColors.subtitleTextColor,
              fontSize: 16.sp,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _facultyObservation() {
    return _detailSection(
      title: 'FACULTY OBSERVATIONS',
      trailing: 'Oct 24, 10:28 AM',
      child: Container(
        padding: EdgeInsets.only(left: 10.w),
        decoration: const BoxDecoration(
          border: Border(
            left: BorderSide(color: AppColors.primaryDark, width: 2),
          ),
        ),
        child: Text(
          '"The cohort demonstrated rapid comprehension of inner function substitution. '
          'Lucas Rivera and Sofia Chen led the front chalkboard review effectively. '
          'For the next session, prepare extra practice worksheets focusing on inverse '
          'trigonometric substitutions before moving on to Related Rates."',
          style: TxtStyle.bodyMedium(
            color: AppColors.subtitleTextColor,
            fontSize: 16.sp,
            height: 1.55,
            fontStyle: FontStyle.italic,
          ),
        ),
      ),
    );
  }

  Widget _detailSection({
    required String title,
    required Widget child,
    String? trailing,
  }) {
    return Container(
      padding: EdgeInsets.only(top: 12.h, bottom: 12.h),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.backgroundsLinesColor)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TxtStyle.titleLarge(
                  color: AppColors.subtitleTextColor,
                  fontSize: 17.sp,
                  fontWeight: FontWeight.w700,
                  letterSpacing: .45,
                ),
              ),

              if (trailing != null) ...[
                Gap(12.w),
                Flexible(
                  child: Text(
                    trailing,
                    textAlign: TextAlign.end,
                    style: TxtStyle.bodyMedium(
                      color: AppColors.subtitleTextColor,
                      fontSize: 14.sp,
                    ),
                  ),
                ),
              ],
            ],
          ),
          SizedBox(height: 9.h),
          child,
        ],
      ),
    );
  }

  Widget _downloadButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {},
        icon: Icon(Icons.download_outlined, size: 17.sp, color: Colors.white),
        label: Text(
          'Download Ledger Slip (PDF)',
          style: TxtStyle.titleLarge(
            color: Colors.white,
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryDark,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6.r),
          ),
        ),
      ),
    );
  }
}
