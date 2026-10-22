import '../../share/export/screen_export.dart';
import '../data/dtos/child_progress_dto.dart';
import '../domain/models/parent_models.dart';
import '../helper/parent_widgets.dart';
import '../presentation/controllers/parent_children_controller.dart';
import '../presentation/controllers/parent_progress_controller.dart';

/// ===============================================================
/// 5. CHILD PROFILE / PERFIL DEL ALUMNO
/// ===============================================================

class ChildProfileScreen extends ConsumerStatefulWidget {
  final ChildModel? child;

  const ChildProfileScreen({super.key, this.child});

  @override
  ConsumerState<ChildProfileScreen> createState() => _ChildProfileScreenState();
}

class _ChildProfileScreenState extends ConsumerState<ChildProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadProgressIfNeeded();
    });
  }

  @override
  void didUpdateWidget(covariant ChildProfileScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.child?.id != widget.child?.id) {
      _loadProgressIfNeeded();
    }
  }

  void _loadProgressIfNeeded() {
    final activeChild = _getActiveChild();
    if (activeChild != null && activeChild.id.isNotEmpty) {
      ref
          .read(parentProgressControllerProvider.notifier)
          .loadProgress(activeChild.id);
    }
  }

  ChildModel? _getActiveChild() {
    final childrenState = ref.read(parentChildrenControllerProvider);
    return widget.child ??
        childrenState.selectedChild ??
        (childrenState.children.isNotEmpty
            ? childrenState.children.first
            : null);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(parentChildrenControllerProvider);
    final activeChild =
        widget.child ??
        state.selectedChild ??
        (state.children.isNotEmpty ? state.children.first : null);

    if (activeChild == null) {
      return Scaffold(
        appBar: simpleAppBar(context, ref.watchTr(AppStrings.childProfile)),
        body: const Center(child: Text('No hay información disponible')),
      );
    }

    final progressState = ref.watch(parentProgressControllerProvider);
    final progress = progressState.progressByChild[activeChild.id];

    return Scaffold(
      backgroundColor: const Color(0xFFF8F7FC),
      appBar: simpleAppBar(context, ref.watchTr(AppStrings.childProfile)),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await ref
                .read(parentProgressControllerProvider.notifier)
                .loadProgress(activeChild.id);
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            padding: EdgeInsets.fromLTRB(14.w, 14.h, 14.w, 30.h),
            child: Column(
              children: [
                _studentHeader(context, ref, activeChild, progress),
                SizedBox(height: 18.h),
                _sectionLabel(
                  ref.watchTr(AppStrings.academicActivity).toUpperCase(),
                ),
                SizedBox(height: 8.h),
                _activityCard(
                  context,
                  ref,
                  activeChild,
                  progress,
                  progressState,
                ),
                SizedBox(height: 13.h),
                _messageCard(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _studentHeader(
    BuildContext context,
    WidgetRef ref,
    ChildModel activeChild,
    ChildProgressDto? progress,
  ) {
    final attendanceText = progress != null
        ? '${progress.attendancePercentage}%'
        : '${activeChild.attendance.toStringAsFixed(1)}%';
    final homeworkText = progress != null
        ? '${progress.homeworkCompletionPercentage}%'
        : '-';
    final subjectsText = progress != null
        ? '${progress.subjects.length}'
        : '-';

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
                  child: Image.network(
                    activeChild.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => Container(
                      color: AppColors.blueSoft,
                      alignment: Alignment.center,
                      child: Text(
                        activeChild.name.isNotEmpty ? activeChild.name[0] : '?',
                        style: TextStyle(
                          fontSize: 20.sp,
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
                      activeChild.name,
                      style: TxtStyle.titleLarge(
                        color: AppColors.text,
                        fontSize: 19.sp,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 3.h),
                    Text(
                      '${activeChild.grade} • ${activeChild.room} • ID: ${activeChild.id}',
                      style: TxtStyle.titleLarge(
                        color: AppColors.subtitleTextColor,
                        fontSize: 14.sp,
                      ),
                    ),
                    SizedBox(height: 3.h),
                    Row(
                      children: [
                        Icon(
                          Icons.school_outlined,
                          size: 16.sp,
                          color: AppColors.primaryDark,
                        ),
                        SizedBox(width: 3.w),
                        Text(
                          'Academia Aula 360',
                          style: TxtStyle.titleLarge(
                            color: AppColors.subtitleTextColor,
                            fontSize: 14.sp,
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
                  ref.watchTr(AppStrings.attendance),
                  attendanceText,
                  AppColors.emeraldGreenColor,
                ),
              ),
              Expanded(
                child: _stat(
                  ref.watchTr(AppStrings.homeworkCompletion),
                  homeworkText,
                  AppColors.primaryDark,
                ),
              ),
              Expanded(
                child: _stat(
                  ref.watchTr(AppStrings.enrolledSubjects),
                  subjectsText,
                  AppColors.orangeColor,
                ),
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
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TxtStyle.titleLarge(
            color: AppColors.subtitleTextColor,
            fontSize: 12.5.sp,
          ),
        ),
        SizedBox(height: 3.h),
        Text(
          value,
          style: TxtStyle.titleLarge(
            color: color,
            fontSize: 16.sp,
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
          fontSize: 15.sp,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _activityCard(
    BuildContext context,
    WidgetRef ref,
    ChildModel activeChild,
    ChildProgressDto? progress,
    ParentProgressState progressState,
  ) {
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
            title: ref.watchTr(AppStrings.navSchedule),
            subtitle: "Clases de hoy y horario",
            onTap: () {
              context.push(RoutePath.schedule);
            },
          ),
          _divider(),
          _activityRow(
            icon: Icons.fact_check_outlined,
            color: AppColors.emeraldGreenColor,
            title: ref.watchTr(AppStrings.attendance),
            subtitle: progress != null
                ? '${progress.attendancePercentage}% registro de asistencia'
                : '${activeChild.attendance.toStringAsFixed(0)}% registro de asistencia',
            onTap: () {
              context.push(RoutePath.attendance, extra: activeChild);
            },
          ),
          _divider(),
          _activityRow(
            icon: Icons.description_outlined,
            color: AppColors.primaryDark,
            title: ref.watchTr(AppStrings.navReports),
            subtitle: 'Resúmenes e informes de clase',
            onTap: () {
              context.push(RoutePath.navigationPages, extra: 2);
            },
          ),
          _divider(),
          _activityRow(
            icon: Icons.assignment_outlined,
            color: AppColors.orangeColor,
            title: 'Tareas',
            subtitle: progress != null
                ? '${progress.homeworkCompletionPercentage}% completadas'
                : 'Ejercicios pendientes',
            onTap: () {
              context.push(RoutePath.homework);
            },
          ),
          _divider(),
          _activityRow(
            icon: Icons.trending_up,
            color: AppColors.purpleAccentColor,
            title: ref.watchTr(AppStrings.academicProgressTitle),
            subtitle: progress != null
                ? '${progress.subjects.length} ${ref.watchTr(AppStrings.subjectsTitle).toLowerCase()} • ${progress.attendancePercentage}% asistencia'
                : 'Notas y evaluación trimestral',
            onTap: () {
              _showProgressBottomSheet(
                context,
                ref,
                activeChild,
                progress,
                progressState,
              );
            },
          ),
          _divider(),
          _activityRow(
            icon: Icons.school_outlined,
            color: AppColors.subtitleTextColor,
            title: ref.watchTr(AppStrings.teacherInfoTitle),
            subtitle: activeChild.parentTeacher.isNotEmpty
                ? activeChild.parentTeacher
                : 'Consultar información del profesor',
            onTap: () {
              context.push(RoutePath.teacherInformation, extra: activeChild);
            },
          ),
        ],
      ),
    );
  }

  void _showProgressBottomSheet(
    BuildContext context,
    WidgetRef ref,
    ChildModel child,
    ChildProgressDto? progress,
    ParentProgressState progressState,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
          ),
          padding: EdgeInsets.fromLTRB(18.w, 14.h, 18.w, 24.h),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 38.w,
                    height: 4.h,
                    margin: EdgeInsets.only(bottom: 14.h),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2.r),
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(8.w),
                          decoration: BoxDecoration(
                            color: AppColors.purpleAccentColor.withValues(
                              alpha: 0.12,
                            ),
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Icon(
                            Icons.trending_up,
                            color: AppColors.purpleAccentColor,
                            size: 20.sp,
                          ),
                        ),
                        SizedBox(width: 10.w),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              ref.watchTr(AppStrings.academicProgressTitle),
                              style: TxtStyle.titleLarge(
                                fontSize: 17.sp,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            Text(
                              '${child.name} • ${child.grade}',
                              style: TxtStyle.bodyMedium(
                                color: AppColors.subtitleTextColor,
                                fontSize: 12.5.sp,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(bottomSheetContext).pop(),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),
                if (progressState.isLoading && progress == null) ...[
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 24.h),
                    child: const Center(
                      child: CircularProgressIndicator(strokeWidth: 2.5),
                    ),
                  ),
                ] else if (progress != null) ...[
                  _metricProgressBar(
                    title: ref.watchTr(AppStrings.attendance),
                    percentage: progress.attendancePercentage,
                    color: AppColors.emeraldGreenColor,
                    icon: Icons.fact_check_outlined,
                  ),
                  SizedBox(height: 14.h),
                  _metricProgressBar(
                    title: ref.watchTr(AppStrings.homeworkCompletion),
                    percentage: progress.homeworkCompletionPercentage,
                    color: AppColors.primaryDark,
                    icon: Icons.assignment_turned_in_outlined,
                  ),
                  SizedBox(height: 18.h),
                  Text(
                    ref.watchTr(AppStrings.enrolledSubjects),
                    style: TxtStyle.titleLarge(
                      fontSize: 14.5.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  if (progress.subjects.isEmpty)
                    Text(
                      'No hay materias matriculadas',
                      style: TxtStyle.bodyMedium(
                        color: AppColors.subtitleTextColor,
                        fontSize: 13.sp,
                      ),
                    )
                  else
                    Wrap(
                      spacing: 8.w,
                      runSpacing: 8.h,
                      children: progress.subjects.map((subject) {
                        return Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10.w,
                            vertical: 6.h,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF4F3F8),
                            borderRadius: BorderRadius.circular(8.r),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.auto_stories_outlined,
                                size: 14.sp,
                                color: AppColors.primaryDark,
                              ),
                              SizedBox(width: 6.w),
                              Text(
                                subject,
                                style: TxtStyle.titleLarge(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.text,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                ] else ...[
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    child: Center(
                      child: Column(
                        children: [
                          Text(
                            progressState.error ?? 'Error al cargar progreso',
                            textAlign: TextAlign.center,
                            style: TxtStyle.bodyMedium(
                              color: AppColors.redColor,
                              fontSize: 13.sp,
                            ),
                          ),
                          SizedBox(height: 10.h),
                          ElevatedButton.icon(
                            onPressed: () {
                              ref
                                  .read(
                                    parentProgressControllerProvider.notifier,
                                  )
                                  .loadProgress(child.id);
                            },
                            icon: const Icon(Icons.refresh, size: 16),
                            label: Text(ref.watchTr(AppStrings.retry)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _metricProgressBar({
    required String title,
    required num percentage,
    required Color color,
    required IconData icon,
  }) {
    final clamped = (percentage / 100.0).clamp(0.0, 1.0);
    final displayVal = percentage is int ? percentage : percentage.round();
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F9FB),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(icon, size: 16.sp, color: color),
                  SizedBox(width: 6.w),
                  Text(
                    title,
                    style: TxtStyle.titleLarge(
                      fontSize: 13.5.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.text,
                    ),
                  ),
                ],
              ),
              Text(
                '$displayVal%',
                style: TxtStyle.titleLarge(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(5.r),
            child: LinearProgressIndicator(
              value: clamped,
              minHeight: 8.h,
              backgroundColor: color.withValues(alpha: 0.15),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
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
                      fontSize: 15.5.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    subtitle,
                    style: TxtStyle.bodyMedium(
                      color: AppColors.subtitleTextColor,
                      fontSize: 13.5.sp,
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

  Widget _messageCard(BuildContext context) {
    return InkWell(
      onTap: () {
        context.push(RoutePath.chatInbox);
      },
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
                    'Mensaje a la Academia',
                    style: TxtStyle.titleLarge(
                      color: AppColors.text,
                      fontSize: 15.5.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    'Contactar con secretaría o tutor',
                    style: TxtStyle.bodyMedium(
                      color: AppColors.subtitleTextColor,
                      fontSize: 13.5.sp,
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
                'Contactar',
                style: TxtStyle.titleLarge(
                  color: AppColors.primaryDark,
                  fontSize: 14.sp,
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
