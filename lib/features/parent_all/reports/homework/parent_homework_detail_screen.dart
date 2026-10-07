import '../../../share/export/screen_export.dart';
import '../../helper/parent_home_helper.dart';

class HomeworkDetailsScreen extends ConsumerWidget {
  final HomeworkModel homework;

  const HomeworkDetailsScreen({super.key, required this.homework});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F7FC),
      appBar: AulaAppBar(title: ref.watchTr(AppStrings.homeworkDetailsTitle), showBack: true),
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: EdgeInsets.fromLTRB(16.w, 18.h, 16.w, 30.h),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _assignmentHeader(ref, homework),
                  SizedBox(height: 15.h),
                  _teacherCard(ref, homework),
                  SizedBox(height: 15.h),
                  _instructions(ref, homework),
                  SizedBox(height: 15.h),
                  _attachmentSection(ref),
                  SizedBox(height: 15.h),
                  _submissionInfo(ref, homework),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _assignmentHeader(WidgetRef ref, HomeworkModel homework) {
    return AulaCard(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            homework.subject.toUpperCase(),
            style: TxtStyle.titleLarge(
              color: AppColors.primary,
              fontSize: 14.sp,
              fontWeight: FontWeight.w800,
              letterSpacing: .5,
            ),
          ),
          SizedBox(height: 7.h),
          Text(
            homework.title,
            style: TxtStyle.titleLarge(
              color: AppColors.text,
              fontSize: 21.sp,
              height: 1.25,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 14.h),
          Row(
            children: [
              _infoChip(Icons.calendar_today_outlined, '26 Oct 2024'),
              SizedBox(width: 8.w),
              _infoChip(Icons.schedule_rounded, '23:59'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _teacherCard(WidgetRef ref, HomeworkModel homework) {
    return AulaCard(
      padding: EdgeInsets.all(14.w),
      child: Row(
        children: [
          const UserAvatar(initials: 'RH', size: 40),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  homework.teacher,
                  style: TxtStyle.titleLarge(
                    color: AppColors.text,
                    fontSize: 17.sp,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 3.h),
                Text(
                  '${ref.watchTr(AppStrings.mockTeacherDept)} • ${homework.subject}',
                  style: TxtStyle.titleLarge(
                    color: AppColors.secondaryText,
                    fontSize: 14.sp,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.chat_bubble_outline_rounded,
            color: AppColors.secondaryText,
            size: 19.sp,
          ),
        ],
      ),
    );
  }

  Widget _instructions(WidgetRef ref, HomeworkModel homework) {
    return AulaCard(
      padding: EdgeInsets.all(15.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            ref.watchTr(AppStrings.instructionsTitle),
            style: TxtStyle.titleLarge(
              color: AppColors.secondaryText,
              fontSize: 14.sp,
              fontWeight: FontWeight.w800,
              letterSpacing: .5,
            ),
          ),
          SizedBox(height: 10.h),
          Text(
            'Escribe un análisis de 500 palabras examinando los temas principales del texto. Cita al menos dos fragmentos específicos de los capítulos trabajados.',
            style: TxtStyle.bodyMedium(
              color: AppColors.text,
              fontSize: 15.sp,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _attachmentSection(WidgetRef ref) {
    return AulaCard(
      padding: EdgeInsets.all(15.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            ref.watchTr(AppStrings.attachmentsTitle),
            style: TxtStyle.titleLarge(
              color: AppColors.secondaryText,
              fontSize: 14.sp,
              fontWeight: FontWeight.w800,
              letterSpacing: .5,
            ),
          ),
          SizedBox(height: 11.h),
          Row(
            children: [
              _fileCard(
                icon: Icons.picture_as_pdf_outlined,
                title: 'PDF o DOCX',
                subtitle: 'Máx 10 MB',
              ),
              SizedBox(width: 10.w),
              _fileCard(
                icon: Icons.description_outlined,
                title: 'Guía de Apoyo',
                subtitle: 'Tema 10–28',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _fileCard({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(11.w),
        decoration: BoxDecoration(
          color: const Color(0xFFF7F7FB),
          borderRadius: BorderRadius.circular(9.r),
          border: Border.all(color: AppColors.backgroundsLinesColor),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primary, size: 21.sp),
            SizedBox(width: 7.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TxtStyle.titleLarge(
                      color: AppColors.text,
                      fontSize: 14.5.sp,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    subtitle,
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

  Widget _submissionInfo(WidgetRef ref, HomeworkModel homework) {
    final completed = homework.status == HomeworkStatus.completed;

    return AulaCard(
      padding: EdgeInsets.all(15.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                ref.watchTr(AppStrings.submissionStatusTitle),
                style: TxtStyle.titleLarge(
                  color: AppColors.text,
                  fontSize: 17.sp,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Spacer(),
              StatusPill(text: completed ? ref.watchTr(AppStrings.completedTab) : ref.watchTr(AppStrings.pendingTab)),
            ],
          ),
          SizedBox(height: 14.h),
          if (completed)
            Text(
              'Entregada correctamente el 22 de Octubre.',
              style: TxtStyle.titleLarge(
                color: const Color(0xFF2B9D70),
                fontSize: 14.5.sp,
                fontWeight: FontWeight.w600,
              ),
            )
          else
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 13.h),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Center(
                child: Text(
                  ref.watchTr(AppStrings.submissionPending),
                  style: TxtStyle.titleLarge(
                    color: Colors.white,
                    fontSize: 15.5.sp,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _infoChip(IconData icon, String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F3F8),
        borderRadius: BorderRadius.circular(7.r),
      ),
      child: Row(
        children: [
          Icon(icon, size: 13.sp, color: AppColors.secondaryText),
          SizedBox(width: 5.w),
          Text(
            text,
            style: TxtStyle.titleLarge(
              color: AppColors.secondaryText,
              fontSize: 13.5.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
