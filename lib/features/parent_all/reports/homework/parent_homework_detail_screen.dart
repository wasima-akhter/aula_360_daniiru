import '../../../share/export/screen_export.dart';
import '../../helper/parent_home_helper.dart';
import 'parent_homework_screen.dart';

class HomeworkDetailsScreen extends StatefulWidget {
  final HomeworkModel homework;

  const HomeworkDetailsScreen({super.key, required this.homework});

  @override
  State<HomeworkDetailsScreen> createState() => _HomeworkDetailsScreenState();
}

class _HomeworkDetailsScreenState extends State<HomeworkDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    final homework = widget.homework;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F7FC),
      appBar: const AulaAppBar(title: 'Homework Details', showBack: true),
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: EdgeInsets.fromLTRB(16.w, 18.h, 16.w, 30.h),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _assignmentHeader(homework),

                  SizedBox(height: 15.h),

                  _teacherCard(homework),

                  SizedBox(height: 15.h),

                  _instructions(homework),

                  SizedBox(height: 15.h),

                  _attachmentSection(),

                  SizedBox(height: 15.h),

                  _submissionInfo(homework),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _assignmentHeader(HomeworkModel homework) {
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
              fontSize: 22.sp,
              height: 1.25,
              fontWeight: FontWeight.w800,
            ),
          ),

          SizedBox(height: 14.h),

          Row(
            children: [
              _infoChip(Icons.calendar_today_outlined, 'Oct 26, 2021'),
              SizedBox(width: 8.w),
              _infoChip(Icons.schedule_rounded, '11:59 PM'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _teacherCard(HomeworkModel homework) {
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
                  'Faculty of English Literature',
                  style: TxtStyle.titleLarge(
                    color: AppColors.secondaryText,
                    fontSize: 15.sp,
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

  Widget _instructions(HomeworkModel homework) {
    return AulaCard(
      padding: EdgeInsets.all(15.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'INSTRUCTIONS',
            style: TxtStyle.titleLarge(
              color: AppColors.secondaryText,
              fontSize: 14.sp,
              fontWeight: FontWeight.w800,
              letterSpacing: .5,
            ),
          ),

          SizedBox(height: 10.h),

          Text(
            'Write a 500-word analysis examining the motivations of a core motif of innocence and moral vulnerability. Cite at least two specific passages from Chapters 10 and 28.',
            style: TxtStyle.bodyMedium(
              color: AppColors.text,
              fontSize: 16.sp,
              height: 1.55,
            ),
          ),
        ],
      ),
    );
  }

  Widget _attachmentSection() {
    return AulaCard(
      padding: EdgeInsets.all(15.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ATTACHMENTS',
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
                title: 'PDF or DOCX',
                subtitle: 'Max 10 MB',
              ),
              SizedBox(width: 10.w),
              _fileCard(
                icon: Icons.description_outlined,
                title: 'Reference',
                subtitle: 'Chapter 10–28',
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
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    subtitle,
                    style: TxtStyle.titleLarge(
                      color: AppColors.secondaryText,
                      fontSize: 13.5.sp,
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

  Widget _submissionInfo(HomeworkModel homework) {
    final completed = homework.status == HomeworkStatus.completed;

    return AulaCard(
      padding: EdgeInsets.all(15.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Submission',
                style: TxtStyle.titleLarge(
                  color: AppColors.text,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Spacer(),
              StatusPill(text: completed ? 'Completed' : 'Pending'),
            ],
          ),

          SizedBox(height: 14.h),

          if (completed)
            Text(
              'Submitted successfully on Oct 22.',
              style: TxtStyle.titleLarge(
                color: const Color(0xFF2B9D70),
                fontSize: 15.sp,
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
                  'Awaiting Submission',
                  style: TxtStyle.titleLarge(
                    color: Colors.white,
                    fontSize: 16.sp,
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
              fontSize: 14.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
