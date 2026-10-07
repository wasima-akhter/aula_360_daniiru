import '../../share/export/screen_export.dart';
import '../domain/models/parent_models.dart';
import '../helper/parent_widgets.dart';
import '../presentation/controllers/parent_attendance_controller.dart';
import '../presentation/controllers/parent_children_controller.dart';

/// ===============================================================
/// 6. ATTENDANCE / ASISTENCIA
/// ===============================================================

class AttendanceScreen extends ConsumerWidget {
  final ChildModel? child;

  const AttendanceScreen({super.key, this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final childrenState = ref.watch(parentChildrenControllerProvider);
    final attendanceState = ref.watch(parentAttendanceControllerProvider);
    final activeChild = child ?? childrenState.selectedChild ?? (childrenState.children.isNotEmpty ? childrenState.children.first : null);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F7FC),
      appBar: simpleAppBar(context, ref.watchTr(AppStrings.attendance)),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.fromLTRB(14.w, 14.h, 14.w, 30.h),
          child: Column(
            children: [
              if (activeChild != null) _summaryCard(ref, activeChild),
              SizedBox(height: 17.h),
              _monthHeader(ref, attendanceState.records.length),
              SizedBox(height: 8.h),
              _attendanceCard(ref, attendanceState.records),
            ],
          ),
        ),
      ),
    );
  }

  Widget _summaryCard(WidgetRef ref, ChildModel child) {
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
                  child: Image.network(
                    child.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => Container(
                      color: AppColors.blueSoft,
                      alignment: Alignment.center,
                      child: Text(
                        child.name.isNotEmpty ? child.name[0] : '?',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
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
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 3.h),
                    Text(
                      '${child.grade} • ${child.room}',
                      style: TxtStyle.titleLarge(
                        color: AppColors.subtitleTextColor,
                        fontSize: 14.sp,
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
                      fontSize: 19.sp,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Text(
                    ref.watchTr(AppStrings.currentQuarter),
                    style: TxtStyle.titleLarge(
                      color: AppColors.subtitleTextColor,
                      fontSize: 13.sp,
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
                  ref.watchTr(AppStrings.present),
                  AppColors.emeraldGreenColor,
                ),
              ),
              Expanded(
                child: _summaryStat(
                  '${child.absent}',
                  ref.watchTr(AppStrings.absent),
                  AppColors.error,
                ),
              ),
              Expanded(
                child: _summaryStat(
                  '${child.late}',
                  ref.watchTr(AppStrings.late),
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
            fontSize: 18.sp,
            fontWeight: FontWeight.w800,
          ),
        ),
        SizedBox(height: 3.h),
        Text(
          label,
          style: TxtStyle.titleLarge(
            color: AppColors.subtitleTextColor,
            fontSize: 14.sp,
          ),
        ),
      ],
    );
  }

  Widget _monthHeader(WidgetRef ref, int sessionsCount) {
    return Row(
      children: [
        Text(
          'OCTUBRE 2024',
          style: TxtStyle.titleLarge(
            color: AppColors.subtitleTextColor,
            fontSize: 14.sp,
            fontWeight: FontWeight.w800,
            letterSpacing: .3,
          ),
        ),
        const Spacer(),
        Text(
          '$sessionsCount ${ref.watchTr(AppStrings.sessionsCount)}',
          style: TxtStyle.titleLarge(
            color: AppColors.subtitleTextColor,
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _attendanceCard(WidgetRef ref, List<AttendanceRecord> records) {
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
            ref: ref,
            subject: 'Matemáticas Avanzadas',
            date: 'Hoy, 24 Oct • 1ª Hora (09:00)',
            status: AttendanceStatus.present,
          ),
          _divider(),
          _attendanceRow(
            ref: ref,
            subject: 'Lengua Castellana y Literatura',
            date: 'Hoy, 24 Oct • 2ª Hora (10:30)',
            status: AttendanceStatus.late,
            detail: '10 min',
          ),
          _divider(),
          _attendanceRow(
            ref: ref,
            subject: 'Biología y Geología',
            date: 'Ayer, 23 Oct • 4ª Hora (13:15)',
            status: AttendanceStatus.present,
          ),
          _divider(),
          _attendanceRow(
            ref: ref,
            subject: 'Historia y Geografía',
            date: 'Ayer, 23 Oct • 5ª Hora (14:45)',
            status: AttendanceStatus.present,
          ),
          _divider(),
          _attendanceRow(
            ref: ref,
            subject: 'Educación Física',
            date: 'Mar, 22 Oct • Pista 2 (08:30)',
            status: AttendanceStatus.excused,
          ),
          _divider(),
          _attendanceRow(
            ref: ref,
            subject: 'Educación Plástica y Visual',
            date: 'Lun, 21 Oct • Taller 4 (13:15)',
            status: AttendanceStatus.present,
          ),
        ],
      ),
    );
  }

  Widget _attendanceRow({
    required WidgetRef ref,
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
                    fontSize: 16.5.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 3.h),
                Text(
                  date,
                  style: TxtStyle.titleLarge(
                    color: AppColors.subtitleTextColor,
                    fontSize: 14.sp,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 7.w),
          _attendanceTag(ref, status, detail: detail),
        ],
      ),
    );
  }

  Widget _attendanceTag(WidgetRef ref, AttendanceStatus status, {String? detail}) {
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
            '${ref.watchTr(status.stringKey)}$suffix',
            style: TxtStyle.titleLarge(
              color: status.textColor,
              fontSize: 13.5.sp,
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
