import '../../parent_all/helper/parent_home_helper.dart';
import '../../share/export/screen_export.dart';
import '../helper/teacher_models.dart';
import '../presentation/controllers/teacher_classes_controller.dart';

/// ===============================================================
/// 2. CLASS DETAILS SCREEN
/// ===============================================================

class TeacherClassDetailScreen extends ConsumerWidget {
  final AcademyClass? academyClass;

  const TeacherClassDetailScreen({super.key, this.academyClass});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final classesState = ref.watch(teacherClassesControllerProvider);
    final currentClass = academyClass ??
        (classesState.todayClasses.isNotEmpty
            ? classesState.todayClasses.first
            : todayClasses.first);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AulaAppBar(title: ref.watchTr(AppStrings.classDetailsTitle), showBack: true),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(16.w, 19.h, 16.w, 35.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _groupLabel(ref, currentClass),
                  SizedBox(height: 7.h),
                  Text(
                    '${ref.watchTr(AppStrings.subjectMath)}\n(Cálculo y Álgebra)',
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
                    label: ref.watchTr(AppStrings.dateTime),
                    value: 'Hoy, 24 Oct • ${currentClass.time} (90 min)',
                  ),
                  _divider(),
                  _detailsRow(
                    label: ref.watchTr(AppStrings.classroom),
                    value: '${currentClass.room}, Planta 1',
                  ),
                  _divider(),
                  _detailsRow(
                    label: ref.watchTr(AppStrings.enrollment),
                    value: '${currentClass.students} ${ref.watchTr(AppStrings.studentsCount)}',
                  ),
                  SizedBox(height: 23.h),
                  Divider(color: AppColors.backgroundsLinesColor, height: 1),
                  SizedBox(height: 18.h),
                  Text(
                    ref.watchTr(AppStrings.sessionInfoTitle),
                    style: TxtStyle.titleLarge(
                      color: AppColors.subtitleTextColor,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w800,
                      letterSpacing: .6,
                    ),
                  ),
                  SizedBox(height: 10.h),
                  _infoCard(
                    title: ref.watchTr(AppStrings.todaysTopic),
                    value: 'Regla de la Cadena y Derivación Implícita',
                  ),
                  SizedBox(height: 10.h),
                  _roomStatusCard(ref),
                  SizedBox(height: 34.h),
                  SizedBox(
                    width: double.infinity,
                    child: AulaPrimaryButton(
                      onTap: () {
                        context.push(RoutePath.teacherAttendance);
                      },
                      text: ref.watchTr(AppStrings.takeAttendance),
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

  Widget _groupLabel(WidgetRef ref, AcademyClass currentClass) {
    return Text(
      '${currentClass.group.toUpperCase()} • ${ref.watchTr(AppStrings.bachillerato1).toUpperCase()}',
      style: TxtStyle.bodyMedium(
        color: AppColors.subtitleTextColor,
        fontSize: 15.sp,
        fontWeight: FontWeight.w700,
        letterSpacing: .4,
      ),
    );
  }

  Widget _detailsRow({required String label, required String value}) {
    return Row(
      children: [
        Text(
          label,
          style: TxtStyle.bodyMedium(
            color: AppColors.subtitleTextColor,
            fontSize: 16.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: TxtStyle.titleLarge(
            color: AppColors.text,
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _divider() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 14.h),
      child: Divider(color: AppColors.backgroundsLinesColor, height: 1),
    );
  }

  Widget _infoCard({required String title, required String value}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: AppColors.backgroundsLinesColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TxtStyle.labelLarge(
              color: AppColors.subtitleTextColor,
              fontSize: 14.5.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 5.h),
          Text(
            value,
            style: TxtStyle.titleLarge(
              color: AppColors.text,
              fontSize: 16.5.sp,
              fontWeight: FontWeight.w700,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _roomStatusCard(WidgetRef ref) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: AppColors.backgroundsLinesColor),
      ),
      child: Row(
        children: [
          Icon(
            Icons.location_on_outlined,
            size: 20.sp,
            color: AppColors.subtitleTextColor,
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              '${ref.watchTr(AppStrings.aula2)} • Planta 1',
              style: TxtStyle.bodyMedium(
                color: AppColors.subtitleTextColor,
                fontSize: 15.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 3.h),
            decoration: BoxDecoration(
              color: const Color(0xffe8f8f0),
              borderRadius: BorderRadius.circular(4.r),
            ),
            child: Text(
              ref.watchTr(AppStrings.activeStatus),
              style: TxtStyle.labelLarge(
                color: AppColors.emeraldGreenColor,
                fontSize: 12.5.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
