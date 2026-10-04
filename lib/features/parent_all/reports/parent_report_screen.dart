import '../../parent_all/helper/parent_home_helper.dart';
import '../../share/export/screen_export.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  int selectedStudent = 0;
  int selectedCategory = 0;

  final List<StudentModel> students = const [
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

  final List<String> categories = const [
    'All Reports',
    'Mathematics',
    'Sciences',
    'English',
  ];

  final List<ReportModel> reports = const [
    ReportModel(
      dateLabel: 'TODAY — WEDNESDAY, OCT 24',
      subject: 'English Literature',
      teacher: 'Ms. Sarah Vance',
      time: '08:30 AM – 09:50 AM',
      category: 'English',
      status: 'Present',
      note:
          'Lucas showed excellent engagement today’s session and provided insightful critique on modern prose.',
      initials: 'SV',
    ),
    ReportModel(
      dateLabel: 'YESTERDAY — TUESDAY, OCT 23',
      subject: 'Advanced Mathematics',
      teacher: 'Mr. Robert Hayes',
      time: '10:30 AM – 12:00 PM',
      category: 'Mathematics',
      status: 'Present',
      note:
          'Completed polynomial factoring test with full mastery (98%). Homework assigned for Chapter 4.',
      initials: 'RH',
    ),
    ReportModel(
      dateLabel: 'YESTERDAY — TUESDAY, OCT 23',
      subject: 'Physics Lab',
      teacher: 'Dr. Angela Bennett',
      time: '02:00 PM – 03:20 PM',
      category: 'Sciences',
      status: 'Present',
      note:
          'Successfully conducted optics refraction experiment. Lab notebook checked and signed. aygdsy aysdgu asgdyas dygasyd yuasdgyasdg asyd gyasg digasi das diuasg dias dias diasdiuasdiuasd uiadi ad',
      initials: 'AB',
    ),
    ReportModel(
      dateLabel: 'MONDAY, OCT 21',
      subject: 'World History',
      teacher: 'Mr. Marcus Brody',
      time: '01:00 PM – 02:15 PM',
      category: 'History',
      status: 'Present',
      note:
          'Active participation in Industrial Revolution debate. Prepared well with assigned readings.',
      initials: 'MB',
    ),
  ];

  List<ReportModel> get filteredReports {
    if (selectedCategory == 0) {
      return reports;
    }

    final category = categories[selectedCategory];

    return reports.where((report) {
      return report.category.toLowerCase() == category.toLowerCase();
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final groupedReports = _groupReports(filteredReports);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F7FC),
      appBar: const AulaAppBar(title: 'Reports', showBack: false),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: EdgeInsets.fromLTRB(16.w, 18.h, 16.w, 20.h),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _studentSection(),

                SizedBox(height: 22.h),

                _categoryTabs(),
              ]),
            ),
          ),

          // =========================================================
          // REPORT SECTIONS
          // =========================================================
          for (final entry in groupedReports.entries) ...[
            SliverPersistentHeader(
              pinned: true,
              delegate: _StickyDateHeaderDelegate(
                height: 38.h,
                child: Container(
                  color: const Color(0xFFF8F7FC),
                  padding: EdgeInsets.fromLTRB(16.w, 0.h, 16.w, 7.h),
                  alignment: Alignment.centerLeft,
                  child: Text(
                    entry.key,
                    style: TxtStyle.titleLarge(
                      color: AppColors.secondaryText,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w800,
                      letterSpacing: .45,
                    ),
                  ),
                ),
              ),
            ),

            SliverPadding(
              padding: EdgeInsets.fromLTRB(16.w, 3.h, 16.w, 5.h),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  for (final report in entry.value) ...[
                    _reportCard(report),
                    SizedBox(height: 12.h),
                  ],
                ]),
              ),
            ),
          ],

          if (filteredReports.isEmpty)
            SliverFillRemaining(hasScrollBody: false, child: _emptyState()),

          SliverToBoxAdapter(child: SizedBox(height: 20.h)),
        ],
      ),
    );
  }

  // ===============================================================
  // STUDENT SECTION
  // ===============================================================

  Widget _studentSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'STUDENT',
              style: TxtStyle.titleLarge(
                color: AppColors.secondaryText,
                fontSize: 16.sp,
                fontWeight: FontWeight.w800,
                letterSpacing: .5,
              ),
            ),
            const Spacer(),
            Text(
              '${students.length} Enrolled',
              style: TxtStyle.titleLarge(
                color: AppColors.primary,
                fontSize: 15.sp,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),

        SizedBox(height: 10.h),

        LayoutBuilder(
          builder: (context, constraints) {
            final cardWidth = (constraints.maxWidth - 10.w) / 2;

            return SizedBox(
              height: 82.h,
              child: Row(
                children: [
                  SizedBox(width: cardWidth, child: _studentCard(0)),
                  SizedBox(width: 10.w),
                  SizedBox(width: cardWidth, child: _studentCard(1)),
                ],
              ),
            );
          },
        ),
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
        padding: EdgeInsets.symmetric(horizontal: 11.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(13.r),
          border: Border.all(
            color: selected
                ? AppColors.primary
                : AppColors.backgroundsLinesColor,
            width: selected ? 1.6.w : 1.w,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: .06),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            UserAvatar(initials: student.initials, size: 40),

            SizedBox(width: 9.w),

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
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w800,
                    ),
                  ),

                  SizedBox(height: 4.h),

                  Text(
                    student.grade,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TxtStyle.titleLarge(
                      color: AppColors.secondaryText,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            if (selected) ...[
              SizedBox(width: 5.w),
              Icon(
                Icons.check_circle_rounded,
                color: AppColors.primary,
                size: 18.sp,
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ===============================================================
  // CATEGORY TABS
  // ===============================================================

  Widget _categoryTabs() {
    return SizedBox(
      height: 43.h,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          children: [
            for (int index = 0; index < categories.length; index++)
              Padding(
                padding: EdgeInsets.only(
                  right: index == categories.length - 1 ? 0 : 8.w,
                ),
                child: _categoryTab(index),
              ),
          ],
        ),
      ),
    );
  }

  Widget _categoryTab(int index) {
    final selected = selectedCategory == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedCategory = index;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : const Color(0xFFEDECF4),
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Text(
          categories[index],
          style: TxtStyle.titleLarge(
            color: selected ? Colors.white : AppColors.secondaryText,
            fontSize: 15.sp,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }

  // ===============================================================
  // REPORT CARD
  // ===============================================================

  Widget _reportCard(ReportModel report) {
    return GestureDetector(
      onTap: () {
        context.push(RoutePath.reportDetail, extra: report);
      },
      child: AulaCard(
        padding: EdgeInsets.all(15.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // -------------------------------------------------------
            // SUBJECT + STATUS
            // -------------------------------------------------------
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        report.subject,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TxtStyle.titleLarge(
                          color: AppColors.text,
                          fontSize: 19.sp,
                          fontWeight: FontWeight.w800,
                        ),
                      ),

                      SizedBox(height: 5.h),

                      Text(
                        report.teacher,
                        style: TxtStyle.titleLarge(
                          color: AppColors.secondaryText,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(width: 10.w),

                const StatusPill(text: 'Present'),
              ],
            ),

            SizedBox(height: 13.h),

            Divider(height: 1, color: AppColors.backgroundsLinesColor),

            SizedBox(height: 12.h),

            // -------------------------------------------------------
            // TIME
            // -------------------------------------------------------
            Row(
              children: [
                Icon(
                  Icons.schedule_rounded,
                  color: AppColors.secondaryText,
                  size: 16.sp,
                ),
                SizedBox(width: 6.w),
                Text(
                  report.time,
                  style: TxtStyle.titleLarge(
                    color: AppColors.secondaryText,
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),

            SizedBox(height: 13.h),

            // -------------------------------------------------------
            // TEACHER NOTE
            // -------------------------------------------------------
            Container(
              width: double.infinity,
              padding: EdgeInsets.fromLTRB(11.w, 10.h, 11.w, 11.h),
              decoration: BoxDecoration(
                color: const Color(0xFFF4F7FF),
                borderRadius: BorderRadius.circular(8.r),
                border: Border(
                  left: BorderSide(color: AppColors.primary, width: 2.5.w),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Teacher Note',
                    style: TxtStyle.titleLarge(
                      color: AppColors.primary,
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w800,
                    ),
                  ),

                  SizedBox(height: 5.h),

                  Text(
                    '"${report.note}"',
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TxtStyle.titleLarge(
                      color: AppColors.text,
                      fontSize: 15.5.sp,
                      height: 1.45,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 13.h),

            // -------------------------------------------------------
            // FOOTER
            // -------------------------------------------------------
            Row(
              children: [
                UserAvatar(initials: report.initials, size: 27),

                SizedBox(width: 7.w),

                Expanded(
                  child: Text(
                    report.teacher,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TxtStyle.titleLarge(
                      color: AppColors.secondaryText,
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                Text(
                  'View Report',
                  style: TxtStyle.titleLarge(
                    color: AppColors.primary,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w800,
                  ),
                ),

                SizedBox(width: 2.w),

                Icon(
                  Icons.arrow_forward_rounded,
                  color: AppColors.primary,
                  size: 15.sp,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ===============================================================
  // EMPTY STATE
  // ===============================================================

  Widget _emptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 35.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 58.w,
              height: 58.w,
              decoration: BoxDecoration(
                color: const Color(0xFFE8EDFF),
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Icon(
                Icons.description_outlined,
                color: AppColors.primary,
                size: 28.sp,
              ),
            ),

            SizedBox(height: 14.h),

            Text(
              'No Reports Found',
              style: TxtStyle.titleLarge(
                color: AppColors.text,
                fontSize: 19.sp,
                fontWeight: FontWeight.w800,
              ),
            ),

            SizedBox(height: 6.h),

            Text(
              'There are no reports available for this category.',
              textAlign: TextAlign.center,
              style: TxtStyle.titleLarge(
                color: AppColors.secondaryText,
                fontSize: 15.sp,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===============================================================
  // GROUPING
  // ===============================================================

  Map<String, List<ReportModel>> _groupReports(List<ReportModel> data) {
    final Map<String, List<ReportModel>> grouped = {};

    for (final report in data) {
      grouped.putIfAbsent(report.dateLabel, () => []);
      grouped[report.dateLabel]!.add(report);
    }

    return grouped;
  }
}

// =================================================================
// MODELS
// =================================================================

class StudentModel {
  final String name;
  final String grade;
  final String initials;

  const StudentModel({
    required this.name,
    required this.grade,
    required this.initials,
  });
}

class ReportModel {
  final String dateLabel;
  final String subject;
  final String teacher;
  final String time;
  final String category;
  final String status;
  final String note;
  final String initials;

  const ReportModel({
    required this.dateLabel,
    required this.subject,
    required this.teacher,
    required this.time,
    required this.category,
    required this.status,
    required this.note,
    required this.initials,
  });
}

// =================================================================
// STICKY HEADER
// =================================================================

class _StickyDateHeaderDelegate extends SliverPersistentHeaderDelegate {
  final double height;
  final Widget child;

  const _StickyDateHeaderDelegate({required this.height, required this.child});

  @override
  double get minExtent => height;

  @override
  double get maxExtent => height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return child;
  }

  @override
  bool shouldRebuild(covariant _StickyDateHeaderDelegate oldDelegate) {
    return oldDelegate.height != height || oldDelegate.child != child;
  }
}
