import 'package:url_launcher/url_launcher.dart';

import '../../share/export/screen_export.dart';
import '../data/dtos/child_teacher_dto.dart';
import '../domain/models/parent_models.dart';
import '../presentation/controllers/parent_children_controller.dart';
import '../presentation/controllers/parent_teachers_controller.dart';

class TeacherInformationScreen extends ConsumerStatefulWidget {
  final ChildModel? child;

  const TeacherInformationScreen({super.key, this.child});

  @override
  ConsumerState<TeacherInformationScreen> createState() =>
      _TeacherInformationScreenState();
}

class _TeacherInformationScreenState
    extends ConsumerState<TeacherInformationScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  void _loadData() {
    final activeChild = widget.child ??
        ref.read(parentChildrenControllerProvider).selectedChild ??
        (ref.read(parentChildrenControllerProvider).children.isNotEmpty
            ? ref.read(parentChildrenControllerProvider).children.first
            : null);

    if (activeChild != null) {
      ref
          .read(parentTeachersControllerProvider.notifier)
          .loadTeachers(activeChild.id);
    }
  }

  Future<void> _launchEmail(String email) async {
    if (email.trim().isEmpty) return;
    final Uri uri = Uri(scheme: 'mailto', path: email.trim());
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final activeChild = widget.child ??
        ref.watch(parentChildrenControllerProvider).selectedChild ??
        (ref.watch(parentChildrenControllerProvider).children.isNotEmpty
            ? ref.watch(parentChildrenControllerProvider).children.first
            : null);

    final teachersState = ref.watch(parentTeachersControllerProvider);
    final teachersController =
        ref.read(parentTeachersControllerProvider.notifier);
    final selectedTeacher = teachersState.selectedTeacher;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F7FC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F7FC),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: Icon(
            Icons.arrow_back,
            color: const Color(0xFF062B78),
            size: 21.sp,
          ),
        ),
        title: Text(
          ref.watchTr(AppStrings.teacherInfoTitle),
          style: TxtStyle.titleLarge(
            color: const Color(0xFF082E78),
            fontSize: 19.sp,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          if (activeChild != null) {
            await teachersController.loadTeachers(activeChild.id);
          }
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 30.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (activeChild != null) ...[
                _studentHeader(ref, activeChild),
                SizedBox(height: 14.h),
              ],
              if (teachersState.isLoading) ...[
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 50.h),
                  child: const Center(child: CircularProgressIndicator()),
                ),
              ] else if (teachersState.error != null) ...[
                _errorView(ref, teachersState.error!, _loadData),
              ] else if (teachersState.teachers.isEmpty) ...[
                _emptyView(ref),
              ] else ...[
                if (teachersState.teachers.length > 1) ...[
                  _teachersSelector(
                    teachersState.teachers,
                    selectedTeacher,
                    teachersController.selectTeacher,
                  ),
                  SizedBox(height: 14.h),
                ],
                if (selectedTeacher != null) ...[
                  _teacherProfile(ref, selectedTeacher),
                  SizedBox(height: 16.h),
                  _communicationCard(ref, selectedTeacher),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _studentHeader(WidgetRef ref, ChildModel child) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: const Color(0xFFE3E6EF)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                child.name,
                style: TxtStyle.titleLarge(
                  color: const Color(0xFF123579),
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              Container(
                width: 7.w,
                height: 7.w,
                decoration: const BoxDecoration(
                  color: Color(0xFF24B47E),
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: 5.w),
              Text(
                ref.watchTr(AppStrings.active),
                style: TxtStyle.titleLarge(
                  color: const Color(0xFF20A779),
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          SizedBox(height: 6.h),
          Row(
            children: [
              Text(
                '${child.grade} • ${child.room}',
                style: TxtStyle.titleLarge(
                  color: const Color(0xFF667085),
                  fontSize: 13.5.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _teachersSelector(
    List<ChildTeacherDto> teachers,
    ChildTeacherDto? selected,
    void Function(ChildTeacherDto) onSelect,
  ) {
    return SizedBox(
      height: 42.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: teachers.length,
        separatorBuilder: (_, _) => SizedBox(width: 8.w),
        itemBuilder: (context, index) {
          final t = teachers[index];
          final isSelected = selected?.id == t.id;
          return ChoiceChip(
            label: Text(
              t.fullName,
              style: TxtStyle.titleLarge(
                fontSize: 13.5.sp,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? Colors.white : AppColors.text,
              ),
            ),
            selected: isSelected,
            selectedColor: AppColors.primary,
            backgroundColor: Colors.white,
            side: BorderSide(
              color: isSelected ? AppColors.primary : AppColors.border,
            ),
            onSelected: (_) => onSelect(t),
          );
        },
      ),
    );
  }

  Widget _teacherProfile(WidgetRef ref, ChildTeacherDto teacher) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(17.w, 17.h, 17.w, 17.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xFFE3E6EF)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .025),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _teacherAvatar(teacher),
              SizedBox(width: 13.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      teacher.fullName,
                      style: TxtStyle.titleLarge(
                        color: const Color(0xFF20283B),
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 3.h),
                    Text(
                      teacher.designation.isNotEmpty
                          ? teacher.designation
                          : ref.watchTr(AppStrings.mockTeacherDept),
                      style: TxtStyle.titleLarge(
                        color: const Color(0xFF082E78),
                        fontSize: 14.5.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (teacher.email.isNotEmpty) ...[
                      SizedBox(height: 2.h),
                      Text(
                        teacher.email,
                        style: TxtStyle.titleLarge(
                          color: const Color(0xFF687083),
                          fontSize: 13.5.sp,
                          height: 1.35,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          if (teacher.bio.isNotEmpty) ...[
            SizedBox(height: 14.h),
            const Divider(height: 1, color: Color(0xFFE2E5EB)),
            SizedBox(height: 12.h),
            Text(
              teacher.bio,
              style: TxtStyle.titleLarge(
                color: const Color(0xFF626B7B),
                fontSize: 14.5.sp,
                height: 1.5,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _teacherAvatar(ChildTeacherDto teacher) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 60.w,
          height: 60.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFFE7EBF2),
            border: Border.all(color: const Color(0xFFE2E6ED), width: 1),
          ),
          child: ClipOval(
            child: (teacher.avatarUrl != null && teacher.avatarUrl!.isNotEmpty)
                ? CustomNetworkImage(
                    imageUrl: teacher.avatarUrl!,
                    fit: BoxFit.cover,
                    width: 60.w,
                    height: 60.w,
                    boxShape: BoxShape.circle,
                    errorWidget: Center(
                      child: Text(
                        teacher.initials,
                        style: TxtStyle.titleLarge(
                          color: AppColors.primary,
                          fontSize: 20.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  )
                : Center(
                    child: Text(
                      teacher.initials,
                      style: TxtStyle.titleLarge(
                        color: AppColors.primary,
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
          ),
        ),
        Positioned(
          right: -2.w,
          bottom: 0,
          child: Container(
            width: 18.w,
            height: 18.w,
            decoration: BoxDecoration(
              color: const Color(0xFF07348A),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: Icon(Icons.verified, color: Colors.white, size: 11.sp),
          ),
        ),
      ],
    );
  }

  Widget _communicationCard(WidgetRef ref, ChildTeacherDto teacher) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(17.w, 18.h, 17.w, 18.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xFFE2E5ED)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.forum_outlined,
                color: const Color(0xFF082E78),
                size: 20.sp,
              ),
              SizedBox(width: 7.w),
              Text(
                ref.watchTr(AppStrings.directCommunication),
                style: TxtStyle.titleLarge(
                  color: const Color(0xFF20283B),
                  fontSize: 17.sp,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          _messageBox(ref),
          if (teacher.email.isNotEmpty) ...[
            SizedBox(height: 12.h),
            _emailBox(teacher.email),
          ],
        ],
      ),
    );
  }

  Widget _messageBox(WidgetRef ref) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(12.w, 11.h, 12.w, 12.h),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F3F8),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            ref.watchTr(AppStrings.portalDirectMessage),
            style: TxtStyle.titleLarge(
              color: const Color(0xFF263149),
              fontSize: 14.5.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 9.h),
          _primaryButton(
            icon: Icons.send_outlined,
            text: ref.watchTr(AppStrings.sendMessageBtn),
            onTap: () {
              AppRouter.navigatorKey.currentContext!.push(RoutePath.chatInbox);
            },
          ),
        ],
      ),
    );
  }

  Widget _emailBox(String email) {
    return InkWell(
      onTap: () => _launchEmail(email),
      borderRadius: BorderRadius.circular(7.r),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(7.r),
          border: Border.all(color: const Color(0xFFDDE2EB)),
        ),
        child: Row(
          children: [
            Icon(Icons.mail_outline,
                color: const Color(0xFF667085), size: 18.sp),
            SizedBox(width: 9.w),
            Expanded(
              child: Text(
                email,
                style: TxtStyle.titleLarge(
                  color: const Color(0xFF123A82),
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Icon(Icons.open_in_new, size: 16.sp, color: AppColors.primary),
          ],
        ),
      ),
    );
  }

  Widget _primaryButton({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 36.h,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, color: Colors.white, size: 14.sp),
        label: Text(
          text,
          style: TxtStyle.titleLarge(
            color: Colors.white,
            fontSize: 14.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: const Color(0xFF052E82),
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(7.r),
          ),
        ),
      ),
    );
  }

  Widget _emptyView(WidgetRef ref) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 40.h, horizontal: 20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xFFE3E6EF)),
      ),
      child: Column(
        children: [
          Icon(
            Icons.person_off_outlined,
            size: 48.sp,
            color: AppColors.subtitleTextColor,
          ),
          SizedBox(height: 12.h),
          Text(
            ref.watchTr(AppStrings.noTeachersFound),
            textAlign: TextAlign.center,
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

  Widget _errorView(WidgetRef ref, String error, VoidCallback onRetry) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 24.h, horizontal: 20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xFFE3E6EF)),
      ),
      child: Column(
        children: [
          Icon(
            Icons.error_outline_rounded,
            size: 44.sp,
            color: AppColors.redColor,
          ),
          SizedBox(height: 10.h),
          Text(
            error,
            textAlign: TextAlign.center,
            style: TxtStyle.bodyMedium(
              color: AppColors.text,
              fontSize: 14.sp,
            ),
          ),
          SizedBox(height: 14.h),
          ElevatedButton(
            onPressed: onRetry,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: Text(ref.watchTr(AppStrings.retry)),
          ),
        ],
      ),
    );
  }
}
