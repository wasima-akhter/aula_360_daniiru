import '../../parent_all/helper/parent_home_helper.dart';
import '../../share/export/screen_export.dart';

class ReportsScreen extends ConsumerStatefulWidget {
  const ReportsScreen({super.key});

  @override
  ConsumerState<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends ConsumerState<ReportsScreen> {
  int selectedStudent = 0;
  int selectedCategory = 0;

  // ─────────────────────────────────────────────────────────────────────────────
  // SAMPLE / MOCK DATA (Spanish Academy Context)
  // ─────────────────────────────────────────────────────────────────────────────

  final List<StudentModel> students = const [
    StudentModel(
      name: 'Lucas Rivera',
      grade: '2º ESO • Aula 3B',
      initials: 'LR',
    ),
    StudentModel(
      name: 'Sophia Rivera',
      grade: '5º Primaria • Aula 1A',
      initials: 'SR',
    ),
  ];

  final List<ReportModel> reports = const [
    ReportModel(
      dateLabel: 'HOY — MIÉRCOLES, 24 OCT',
      subject: 'Lengua Castellana y Literatura',
      teacher: 'Dña. Sarah Vance',
      time: '08:30 – 09:50',
      category: 'Lengua',
      status: 'Presente',
      note:
          'Lucas mostró excelente participación en la sesión de hoy y aportó reflexiones muy acertadas.',
      initials: 'SV',
    ),
    ReportModel(
      dateLabel: 'AYER — MARTES, 23 OCT',
      subject: 'Matemáticas Avanzadas',
      teacher: 'D. Roberto Hayes',
      time: '10:30 – 12:00',
      category: 'Matemáticas',
      status: 'Presente',
      note:
          'Superó la prueba de factorización de polinomios con nota sobresaliente (98%). Tarea asignada del tema 4.',
      initials: 'RH',
    ),
    ReportModel(
      dateLabel: 'AYER — MARTES, 23 OCT',
      subject: 'Física y Química',
      teacher: 'Dra. Ángela Bennett',
      time: '14:00 – 15:20',
      category: 'Ciencias',
      status: 'Presente',
      note:
          'Realizó con éxito la práctica de óptica y refracción en el laboratorio. Cuaderno revisado y firmado.',
      initials: 'AB',
    ),
    ReportModel(
      dateLabel: 'LUNES, 21 OCT',
      subject: 'Geografía e Historia',
      teacher: 'D. Marcos Brody',
      time: '13:00 – 14:15',
      category: 'Historia',
      status: 'Presente',
      note:
          'Participación activa en el debate. Excelente preparación con las lecturas asignadas.',
      initials: 'MB',
    ),
  ];

  List<String> _getCategories() {
    return [
      ref.watchTr(AppStrings.allReports),
      ref.watchTr(AppStrings.subjectMath),
      ref.watchTr(AppStrings.subjectPhysicsChemistry),
      ref.watchTr(AppStrings.subjectSpanishLanguage),
    ];
  }

  List<ReportModel> get filteredReports {
    if (selectedCategory == 0) {
      return reports;
    }

    final categories = _getCategories();
    final category = categories[selectedCategory];

    return reports.where((report) {
      return report.category.toLowerCase().contains(category.toLowerCase()) ||
          category.toLowerCase().contains(report.category.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final groupedReports = _groupReports(filteredReports);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F7FC),
      appBar: AulaAppBar(title: ref.watchTr(AppStrings.navReports), showBack: false),
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
                      fontSize: 13.5.sp,
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
              ref.watchTr(AppStrings.studentInfoTitle).toUpperCase(),
              style: TxtStyle.titleLarge(
                color: AppColors.secondaryText,
                fontSize: 14.sp,
                fontWeight: FontWeight.w800,
                letterSpacing: .5,
              ),
            ),
            const Spacer(),
            Text(
              '${students.length} ${ref.watchTr(AppStrings.active)}',
              style: TxtStyle.titleLarge(
                color: AppColors.primary,
                fontSize: 14.sp,
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
                      fontSize: 15.sp,
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
                      fontSize: 13.sp,
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
    final categories = _getCategories();

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
                child: _categoryTab(index, categories[index]),
              ),
          ],
        ),
      ),
    );
  }

  Widget _categoryTab(int index, String title) {
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
          title,
          style: TxtStyle.titleLarge(
            color: selected ? Colors.white : AppColors.secondaryText,
            fontSize: 14.5.sp,
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
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(height: 5.h),
                      Text(
                        report.teacher,
                        style: TxtStyle.titleLarge(
                          color: AppColors.secondaryText,
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 10.w),
                StatusPill(text: ref.watchTr(AppStrings.present)),
              ],
            ),

            SizedBox(height: 13.h),
            Divider(height: 1, color: AppColors.backgroundsLinesColor),
            SizedBox(height: 12.h),

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
                    fontSize: 14.5.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),

            SizedBox(height: 13.h),

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
                    ref.watchTr(AppStrings.teacherNote),
                    style: TxtStyle.titleLarge(
                      color: AppColors.primary,
                      fontSize: 14.5.sp,
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
                      fontSize: 14.5.sp,
                      height: 1.45,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 13.h),

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
                      fontSize: 14.5.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Text(
                  ref.watchTr(AppStrings.viewReport),
                  style: TxtStyle.titleLarge(
                    color: AppColors.primary,
                    fontSize: 13.5.sp,
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
              ref.watchTr(AppStrings.noReportsFound),
              style: TxtStyle.titleLarge(
                color: AppColors.text,
                fontSize: 18.sp,
                fontWeight: FontWeight.w800,
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              ref.watchTr(AppStrings.noReportsForCategory),
              textAlign: TextAlign.center,
              style: TxtStyle.titleLarge(
                color: AppColors.secondaryText,
                fontSize: 14.5.sp,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

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
