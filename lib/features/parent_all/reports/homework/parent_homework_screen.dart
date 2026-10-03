import '../../../share/export/screen_export.dart';
import '../../helper/parent_home_helper.dart';
import '../parent_report_screen.dart';

class HomeworkScreen extends StatefulWidget {
  const HomeworkScreen({super.key});

  @override
  State<HomeworkScreen> createState() => _HomeworkScreenState();
}

class _HomeworkScreenState extends State<HomeworkScreen> {
  int selectedStudent = 0;
  int selectedTab = 0;

  final students = const [
    StudentModel(
      name: 'Lucas Rivera',
      grade: 'Grade 8 • Room 3B',
      initials: 'LR',
    ),
    StudentModel(
      name: 'Sophia Rivera',
      grade: 'Grade 5 • Room 1A',
      initials: 'SR',
    ),
  ];

  final tabs = const ['All 5', 'Pending 3', 'Completed 2'];

  final homework = const [
    HomeworkModel(
      subject: 'English Literature',
      teacher: 'Ms. Sarah Vance',
      period: 'Period 3',
      title: 'Essay Draft: Analysis of Character Motivations in Chapter 3',
      description:
          'Write a 500-word analytical draft evaluating character conflict and syntactic rhetoric.',
      status: HomeworkStatus.pending,
      deadline: 'Due Oct 26',
      time: '05:00 PM',
    ),
    HomeworkModel(
      subject: 'Advanced Mathematics',
      teacher: 'Mr. Robert Hayes',
      period: 'Period 3',
      title: 'Problem Set 4: Quadratic Polynomial Graphing',
      description:
          'Complete textbook exercises 4.2 through 4.5. Graph transformations and label intercepts.',
      status: HomeworkStatus.pending,
      deadline: 'Monday, Oct 29',
      time: '08:30 AM',
    ),
    HomeworkModel(
      subject: 'Physics Lab',
      teacher: 'Dr. Angela Bennett',
      period: 'Period 5',
      title: 'Refraction Index & Optics Lab Sheet',
      description:
          'Summarize data points from Wednesday’s bench experiment and calculate the index of refraction.',
      status: HomeworkStatus.pending,
      deadline: 'Wednesday, Oct 31',
      time: '11:59 PM',
    ),
    HomeworkModel(
      subject: 'World History',
      teacher: 'Mr. Marcus Brody',
      period: 'Period 2',
      title: 'Primary Source Review: Industrial Revolution',
      description:
          'Annotated reading of nineteenth-century textile mill testimonies.',
      status: HomeworkStatus.completed,
      deadline: 'Completed Oct 22',
      time: '',
    ),
    HomeworkModel(
      subject: 'English Literature',
      teacher: 'Ms. Sarah Vance',
      period: 'Period 3',
      title: 'Poetry Analysis: Structure and Meter',
      description: 'Metrical analysis and poetic devices breakdown.',
      status: HomeworkStatus.completed,
      deadline: 'Completed Oct 19',
      time: '',
    ),
  ];

  List<HomeworkModel> get filteredHomework {
    if (selectedTab == 0) {
      return homework;
    }

    if (selectedTab == 1) {
      return homework
          .where((item) => item.status == HomeworkStatus.pending)
          .toList();
    }

    return homework
        .where((item) => item.status == HomeworkStatus.completed)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F7FC),
      appBar: const AulaAppBar(title: 'Homework', showBack: true),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: EdgeInsets.fromLTRB(16.w, 18.h, 16.w, 20.h),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _studentSelector(),

                SizedBox(height: 22.h),

                _tabs(),
              ]),
            ),
          ),

          SliverPadding(
            padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 30.h),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                for (final item in filteredHomework) ...[
                  _homeworkCard(item),
                  SizedBox(height: 12.h),
                ],
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _studentSelector() {
    return Row(
      children: [
        for (int i = 0; i < students.length; i++) ...[
          Expanded(child: _studentCard(i)),
          if (i != students.length - 1) SizedBox(width: 9.w),
        ],
      ],
    );
  }

  Widget _studentCard(int index) {
    final student = students[index];
    final selected = selectedStudent == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedStudent = index;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
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
                      fontSize: 12.sp,
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
                      fontSize: 11.sp,
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

  Widget _tabs() {
    return SizedBox(
      height: 40.h,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            for (int i = 0; i < tabs.length; i++)
              Padding(
                padding: EdgeInsets.only(right: 8.w),
                child: _tab(i),
              ),
          ],
        ),
      ),
    );
  }

  Widget _tab(int index) {
    final selected = selectedTab == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedTab = index;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 9.h),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : const Color(0xFFEDECF4),
          borderRadius: BorderRadius.circular(9.r),
        ),
        child: Text(
          tabs[index],
          style: TxtStyle.titleLarge(
            color: selected ? Colors.white : AppColors.secondaryText,
            fontSize: 12.sp,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }

  Widget _homeworkCard(HomeworkModel item) {
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
                fontSize: 11.sp,
                fontWeight: FontWeight.w800,
                letterSpacing: .4,
              ),
            ),

            SizedBox(height: 6.h),

            Text(
              item.title,
              style: TxtStyle.titleLarge(
                color: AppColors.text,
                fontSize: 15.sp,
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
                fontSize: 11.sp,
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
                    fontSize: 11.5.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const Spacer(),

                Text(
                  'View Details',
                  style: TxtStyle.titleLarge(
                    color: AppColors.primary,
                    fontSize: 10.sp,
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

enum HomeworkStatus { pending, completed }

class HomeworkModel {
  final String subject;
  final String teacher;
  final String period;
  final String title;
  final String description;
  final HomeworkStatus status;
  final String deadline;
  final String time;

  const HomeworkModel({
    required this.subject,
    required this.teacher,
    required this.period,
    required this.title,
    required this.description,
    required this.status,
    required this.deadline,
    required this.time,
  });
}
