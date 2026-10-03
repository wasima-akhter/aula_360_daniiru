import '../../share/export/screen_export.dart';
import '../helper/parent_enums.dart';
import '../helper/parent_models.dart';
import '../helper/parent_widgets.dart';

/// ===============================================================
/// 6. ATTENDANCE
/// ===============================================================

class AttendanceScreen extends StatelessWidget {
  const AttendanceScreen({super.key});

  final child = sophiaChild;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F7FC),
      appBar: simpleAppBar(context, 'Attendance'),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.fromLTRB(14.w, 14.h, 14.w, 30.h),
          child: Column(
            children: [
              _summaryCard(),
              SizedBox(height: 17.h),
              _monthHeader(),
              SizedBox(height: 8.h),
              _attendanceCard(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _summaryCard() {
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
                width: 42.w,
                height: 42.w,
                decoration: BoxDecoration(
                  color: AppColors.blueSoft,
                  shape: BoxShape.circle,
                ),
                child: ClipOval(
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
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 3.h),
                    Text(
                      '${child.grade} • ${child.room}',
                      style: TxtStyle.titleLarge(
                        color: AppColors.subtitleTextColor,
                        fontSize: 12.5.sp,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${child.attendance.toStringAsFixed(0)}%',
                    style: TxtStyle.titleLarge(
                      color: AppColors.primaryDark,
                      fontSize: 17.sp,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Text(
                    'Term Record',
                    style: TxtStyle.titleLarge(
                      color: AppColors.subtitleTextColor,
                      fontSize: 11.sp,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 11.h),
          Divider(height: 1, color: AppColors.backgroundsLinesColor),
          SizedBox(height: 10.h),
          Row(
            children: [
              Expanded(
                child: _summaryStat(
                  '${child.present}',
                  'Present',
                  AppColors.emeraldGreenColor,
                ),
              ),
              Expanded(
                child: _summaryStat(
                  '${child.absent}',
                  'Absent',
                  AppColors.error,
                ),
              ),
              Expanded(
                child: _summaryStat(
                  '${child.late}',
                  'Late',
                  AppColors.orangeColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _summaryStat(String value, String label, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TxtStyle.titleLarge(
            color: color,
            fontSize: 16.sp,
            fontWeight: FontWeight.w800,
          ),
        ),
        SizedBox(height: 3.h),
        Text(
          label,
          style: TxtStyle.titleLarge(
            color: AppColors.subtitleTextColor,
            fontSize: 12.sp,
          ),
        ),
      ],
    );
  }

  Widget _monthHeader() {
    return Row(
      children: [
        Text(
          'OCTOBER 2024',
          style: TxtStyle.titleLarge(
            color: AppColors.subtitleTextColor,
            fontSize: 13.sp,
            fontWeight: FontWeight.w800,
            letterSpacing: .3,
          ),
        ),
        const Spacer(),
        Text(
          '6 Sessions',
          style: TxtStyle.titleLarge(
            color: AppColors.subtitleTextColor,
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _attendanceCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(9.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          _attendanceRow(
            subject: 'Advanced Mathematics',
            date: 'Today, Oct 24 • Period 1 (09:00 AM)',
            status: AttendanceStatus.present,
          ),
          _divider(),
          _attendanceRow(
            subject: 'English Literature',
            date: 'Today, Oct 24 • Period 2 (10:30 AM)',
            status: AttendanceStatus.late,
            detail: '10m',
          ),
          _divider(),
          _attendanceRow(
            subject: 'Biology & Science Lab',
            date: 'Yesterday, Oct 23 • Period 4 (01:15 PM)',
            status: AttendanceStatus.present,
          ),
          _divider(),
          _attendanceRow(
            subject: 'World History',
            date: 'Yesterday, Oct 23 • Period 5 (02:45 PM)',
            status: AttendanceStatus.present,
          ),
          _divider(),
          _attendanceRow(
            subject: 'Physical Education',
            date: 'Tue, Oct 22 • Field 2 (08:30 AM)',
            status: AttendanceStatus.excused,
          ),
          _divider(),
          _attendanceRow(
            subject: 'Art & Design',
            date: 'Mon, Oct 21 • Studio 4 (01:15 PM)',
            status: AttendanceStatus.present,
          ),
        ],
      ),
    );
  }

  Widget _attendanceRow({
    required String subject,
    required String date,
    required AttendanceStatus status,
    String? detail,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 11.w, vertical: 11.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  subject,
                  style: TxtStyle.titleLarge(
                    letterSpacing: 0.1,
                    color: AppColors.text,
                    fontSize: 14.5.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 3.h),
                Text(
                  date,
                  style: TxtStyle.titleLarge(
                    color: AppColors.subtitleTextColor,
                    fontSize: 12.sp,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 7.w),
          _attendanceTag(status, detail: detail),
        ],
      ),
    );
  }

  Widget _attendanceTag(AttendanceStatus status, {String? detail}) {
    final suffix = detail == null ? '' : ' ($detail)';

    final IconData icon = switch (status) {
      AttendanceStatus.excused => Icons.close_rounded,
      AttendanceStatus.late => Icons.access_time_rounded,
      _ => Icons.check_rounded,
    };

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: status.backgroundColor,
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: status.textColor, size: 12.sp),
          SizedBox(width: 3.w),
          Text(
            '${status.label}$suffix',
            style: TxtStyle.titleLarge(
              color: status.textColor,
              fontSize: 11.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() {
    return Container(height: 1, color: AppColors.backgroundsLinesColor);
  }
}
