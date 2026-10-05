import '../../../share/export/screen_export.dart';
import '../../helper/parent_home_helper.dart';
import '../parent_report_screen.dart';

class HomeworkScreen extends ConsumerStatefulWidget {
  const HomeworkScreen({super.key});

  @override
  ConsumerState<HomeworkScreen> createState() => _HomeworkScreenState();
}

class _HomeworkScreenState extends ConsumerState<HomeworkScreen> {
  int selectedStudent = 0;
  int selectedTab = 0;

  // ─────────────────────────────────────────────────────────────────────────────
  // SAMPLE / MOCK DATA (Spanish Academy Context)
  // ─────────────────────────────────────────────────────────────────────────────

  final students = const [
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

  final homework = const [
    HomeworkModel(
      subject: 'Lengua Castellana y Literatura',
      teacher: 'Dña. Sarah Vance',
      period: '3ª Hora',
      title: 'Borrador: Análisis literario del capítulo 3',
      description:
          'Escribe un borrador de 500 palabras evaluando el conflicto y los recursos expresivos.',
      status: HomeworkStatus.pending,
      deadline: 'Entrega: 26 Oct',
      time: '17:00',
    ),
    HomeworkModel(
      subject: 'Matemáticas Avanzadas',
      teacher: 'D. Roberto Hayes',
      period: '3ª Hora',
      title: 'Relación de Problemas: Polinomios y Funciones',
      description:
          'Ejercicios 4.2 al 4.5 del libro de texto. Representación gráfica de funciones.',
      status: HomeworkStatus.pending,
      deadline: 'Lunes, 29 Oct',
      time: '08:30',
    ),
    HomeworkModel(
      subject: 'Física y Química',
      teacher: 'Dra. Ángela Bennett',
      period: '5ª Hora',
      title: 'Ficha de Laboratorio: Óptica y Refracción',
      description:
          'Resumir los datos experimentales obtenidos el miércoles y calcular el índice de refracción.',
      status: HomeworkStatus.pending,
      deadline: 'Miércoles, 31 Oct',
      time: '23:59',
    ),
    HomeworkModel(
      subject: 'Geografía e Historia',
      teacher: 'D. Marcos Brody',
      period: '2ª Hora',
      title: 'Comentario de Texto: Revolución Industrial',
      description:
          'Lectura y comentario sobre testimonios históricos del siglo XIX.',
      status: HomeworkStatus.completed,
      deadline: 'Completada: 22 Oct',
      time: '',
    ),
    HomeworkModel(
      subject: 'Lengua Castellana y Literatura',
      teacher: 'Dña. Sarah Vance',
      period: '3ª Hora',
      title: 'Análisis Poético: Métrica y Figuras',
      description: 'Métrica y figuras retóricas en el Siglo de Oro.',
      status: HomeworkStatus.completed,
      deadline: 'Completada: 19 Oct',
      time: '',
    ),
  ];

  List<String> _getTabs() {
    return [
      '${ref.watchTr(AppStrings.allTab)} (5)',
      '${ref.watchTr(AppStrings.pendingTab)} (3)',
      '${ref.watchTr(AppStrings.completedTab)} (2)',
    ];
  }

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
      appBar: AulaAppBar(title: ref.watchTr(AppStrings.homeworkTitle), showBack: true),
      body: SafeArea(
        child: CustomScrollView(
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

  Widget _tabs() {
    final tabs = _getTabs();

    return SizedBox(
      height: 40.h,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            for (int i = 0; i < tabs.length; i++)
              Padding(
                padding: EdgeInsets.only(right: 8.w),
                child: _tab(i, tabs[i]),
              ),
          ],
        ),
      ),
    );
  }

  Widget _tab(int index, String title) {
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
