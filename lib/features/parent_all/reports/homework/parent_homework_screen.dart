import '../../../share/export/screen_export.dart';
import '../../helper/parent_home_helper.dart';
import '../../presentation/controllers/parent_homework_controller.dart';

class HomeworkScreen extends ConsumerWidget {
  const HomeworkScreen({super.key});

  List<String> _getTabs(WidgetRef ref, int total, int pending, int completed) {
    return [
      '${ref.watchTr(AppStrings.allTab)} ($total)',
      '${ref.watchTr(AppStrings.pendingTab)} ($pending)',
      '${ref.watchTr(AppStrings.completedTab)} ($completed)',
    ];
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(parentHomeworkControllerProvider);
    final controller = ref.read(parentHomeworkControllerProvider.notifier);

    final pendingCount =
        state.homework.where((h) => h.status == HomeworkStatus.pending).length;
    final completedCount =
        state.homework.where((h) => h.status == HomeworkStatus.completed).length;

    final tabs = _getTabs(ref, state.homework.length, pendingCount, completedCount);
    final filtered = state.filteredHomework;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F7FC),
      appBar: AulaAppBar(title: ref.watchTr(AppStrings.homeworkTitle), showBack: true),
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: EdgeInsets.fromLTRB(16.w, 18.h, 16.w, 20.h),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _studentSelector(state, controller),
                  SizedBox(height: 22.h),
                  _tabs(state, controller, tabs),
                ]),
              ),
            ),

            SliverPadding(
              padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 30.h),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  for (final item in filtered) ...[
                    _homeworkCard(context, ref, item),
                    SizedBox(height: 12.h),
                  ],
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _studentSelector(
    ParentHomeworkState state,
    ParentHomeworkController controller,
  ) {
    return Row(
      children: [
        for (int i = 0; i < state.students.length; i++) ...[
          Expanded(child: _studentCard(state, controller, i)),
          if (i != state.students.length - 1) SizedBox(width: 9.w),
        ],
      ],
    );
  }

  Widget _studentCard(
    ParentHomeworkState state,
    ParentHomeworkController controller,
    int index,
  ) {
    final student = state.students[index];
    final selected = state.selectedStudentIndex == index;

    return GestureDetector(
      onTap: () => controller.selectStudent(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        height: 72.h,
        padding: EdgeInsets.all(10.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: selected
                ? AppColors.primary
                : AppColors.backgroundsLinesColor,
            width: selected ? 1.6 : 1,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: .08),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            UserAvatar(initials: student.initials, size: 36),
            SizedBox(width: 8.w),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    student.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TxtStyle.titleLarge(
                      color: AppColors.text,
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: 3.h),
                  Text(
                    student.grade,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TxtStyle.titleLarge(
                      color: AppColors.secondaryText,
                      fontSize: 13.sp,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tabs(
    ParentHomeworkState state,
    ParentHomeworkController controller,
    List<String> tabs,
  ) {
    return SizedBox(
      height: 40.h,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          children: [
            for (int i = 0; i < tabs.length; i++)
              Padding(
                padding: EdgeInsets.only(right: 8.w),
                child: _tab(state, controller, i, tabs[i]),
              ),
          ],
        ),
      ),
    );
  }

  Widget _tab(
    ParentHomeworkState state,
    ParentHomeworkController controller,
    int index,
    String title,
  ) {
    final selected = state.selectedTab == index;

    return GestureDetector(
      onTap: () => controller.selectTab(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 9.h),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : const Color(0xFFEDECF4),
          borderRadius: BorderRadius.circular(9.r),
        ),
        child: Text(
          title,
          style: TxtStyle.titleLarge(
            color: selected ? Colors.white : AppColors.secondaryText,
            fontSize: 14.sp,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }

  Widget _homeworkCard(BuildContext context, WidgetRef ref, HomeworkModel item) {
    final completed = item.status == HomeworkStatus.completed;

    return GestureDetector(
      onTap: () {
        context.push(RoutePath.homeworkDetail, extra: item);
      },
      child: AulaCard(
        padding: EdgeInsets.all(15.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item.subject.toUpperCase(),
              style: TxtStyle.titleLarge(
                color: AppColors.primary,
                fontSize: 13.sp,
                fontWeight: FontWeight.w800,
                letterSpacing: .4,
              ),
            ),

            SizedBox(height: 6.h),

            Text(
              item.title,
              style: TxtStyle.titleLarge(
                color: AppColors.text,
                fontSize: 17.sp,
                height: 1.3,
                fontWeight: FontWeight.w800,
              ),
            ),

            SizedBox(height: 7.h),

            Text(
              item.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TxtStyle.bodyMedium(
                color: AppColors.secondaryText,
                fontSize: 13.5.sp,
                height: 1.4,
              ),
            ),

            SizedBox(height: 13.h),

            Row(
              children: [
                Icon(
                  completed
                      ? Icons.check_circle_outline_rounded
                      : Icons.schedule_rounded,
                  size: 16.sp,
                  color: completed
                      ? const Color(0xFF2B9D70)
                      : const Color(0xFFE68A27),
                ),
                SizedBox(width: 5.w),
                Text(
                  item.deadline,
                  style: TxtStyle.titleLarge(
                    color: completed
                        ? const Color(0xFF2B9D70)
                        : const Color(0xFFE68A27),
                    fontSize: 13.5.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const Spacer(),

                Text(
                  ref.watchTr(AppStrings.viewDetails),
                  style: TxtStyle.titleLarge(
                    color: AppColors.primary,
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w800,
                  ),
                ),

                Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.primary,
                  size: 17.sp,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
