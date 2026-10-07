import '../../parent_all/helper/parent_home_helper.dart';
import '../../share/export/screen_export.dart';

/// ===============================================================
/// REPORT DETAILS SCREEN
/// ===============================================================

class TeacherReportDetailsScreen extends ConsumerWidget {
  const TeacherReportDetailsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.softBackground,
      appBar: AulaAppBar(
        title: ref.watchTr(AppStrings.reportDetailTitle),
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
            _recordHeader(ref),
            SizedBox(height: 17.h),
            _attendanceSection(ref),
            SizedBox(height: 17.h),
            _contentSection(ref),
            SizedBox(height: 17.h),
            _homeworkSection(ref),
            SizedBox(height: 17.h),
            _facultyObservation(ref),
            SizedBox(height: 19.h),
            _downloadButton(ref),
          ],
        ),
      ),
    );
  }

  Widget _recordHeader(WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${ref.watchTr(AppStrings.attendanceRecordTitle)} • #AR-8041',
          style: TxtStyle.titleLarge(
            color: AppColors.subtitleTextColor,
            fontSize: 15.sp,
            fontWeight: FontWeight.w700,
            letterSpacing: .5,
          ),
        ),
        SizedBox(height: 7.h),
        Text(
          'Matemáticas Avanzadas (Cálculo y Álgebra)',
          style: TxtStyle.titleLarge(
            color: AppColors.text,
            fontSize: 22.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: 5.h),
        Text(
          '${ref.watchTr(AppStrings.groupA)}  •  ${ref.watchTr(AppStrings.aula2)}  •  24 Oct 2024',
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
              TextSpan(text: ref.watchTr(AppStrings.facultyPrefix)),
              TextSpan(
                text: 'Dra. Sarah Jenkins',
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

  Widget _attendanceSection(WidgetRef ref) {
    return _detailSection(
      title: ref.watchTr(AppStrings.attendanceAndParticipationTitle),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '18 de 18 Presentes (100%)',
            style: TxtStyle.titleLarge(
              color: AppColors.text,
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 5.h),
          Text(
            'Valoración de actitud: 5.0 / 5.0 • Rigor académico: 4.8 / 5.0',
            style: TxtStyle.bodyMedium(
              color: AppColors.subtitleTextColor,
              fontSize: 16.sp,
            ),
          ),
        ],
      ),
    );
  }

  Widget _contentSection(WidgetRef ref) {
    return _detailSection(
      title: ref.watchTr(AppStrings.contentDeliveredTitle).toUpperCase(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tema 4: Regla de la cadena y derivación implícita',
            style: TxtStyle.titleLarge(
              color: AppColors.text,
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            'Se realizaron demostraciones en pizarra para funciones compuestas y trigonométricas. '
            'Los 18 alumnos completaron 4 ejercicios prácticos en parejas, '
            'seguidos de las actividades 14–28 del Tema 4.2.',
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

  Widget _homeworkSection(WidgetRef ref) {
    return _detailSection(
      title: ref.watchTr(AppStrings.assignedTasksTitle).toUpperCase(),
      trailing: 'Entrega: 29 Oct',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Relación 4: Derivación implícita y funciones compuestas',
            style: TxtStyle.titleLarge(
              color: AppColors.text,
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            'Ejercicios 12–25 del cuaderno de actividades (págs. 88–91) con justificación completa.',
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

  Widget _facultyObservation(WidgetRef ref) {
    return _detailSection(
      title: ref.watchTr(AppStrings.facultyObservationTitle),
      trailing: '24 Oct, 10:28',
      child: Container(
        padding: EdgeInsets.only(left: 10.w),
        decoration: const BoxDecoration(
          border: Border(
            left: BorderSide(color: AppColors.primaryDark, width: 2),
          ),
        ),
        child: Text(
          '"El grupo demostró una rápida asimilación de la regla de la cadena. '
          'Lucas Rivera y Sofía Chen guiaron con solvencia la resolución en pizarra. '
          'Para la próxima sesión, reforzar con ejercicios de trigonometría inversa antes '
          'de pasar a aplicaciones de la derivada."',
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
              Flexible(
                child: Text(
                  title,
                  style: TxtStyle.titleLarge(
                    color: AppColors.subtitleTextColor,
                    fontSize: 17.sp,
                    fontWeight: FontWeight.w700,
                    letterSpacing: .45,
                  ),
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

  Widget _downloadButton(WidgetRef ref) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {},
        icon: Icon(Icons.download_outlined, size: 17.sp, color: Colors.white),
        label: Text(
          ref.watchTr(AppStrings.downloadOfficialRecordPdf),
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
