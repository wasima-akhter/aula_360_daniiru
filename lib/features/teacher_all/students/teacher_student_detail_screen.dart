import '../../parent_all/helper/parent_home_helper.dart';
import '../../share/export/screen_export.dart';

class TeacherFacultyNotesNotifier extends Notifier<List<String>> {
  @override
  List<String> build() => [];

  void addNote(String note) {
    state = [...state, note];
  }
}

final teacherFacultyNotesProvider =
    NotifierProvider<TeacherFacultyNotesNotifier, List<String>>(
  TeacherFacultyNotesNotifier.new,
);

/// ===============================================================
/// STUDENT DETAILS SCREEN
/// ===============================================================

class TeacherStudentDetailsScreen extends ConsumerWidget {
  const TeacherStudentDetailsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final facultyNotes = ref.watch(teacherFacultyNotesProvider);

    return Scaffold(
      backgroundColor: AppColors.softBackground,
      appBar: AulaAppBar(
        title: ref.watchTr(AppStrings.studentDetailsTitle),
        showBack: true,
        actions: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: const Color(0xfff0f3f8),
              borderRadius: BorderRadius.circular(4.r),
            ),
            child: Text(
              '#ST-2041',
              style: TxtStyle.bodyMedium(
                color: AppColors.subtitleTextColor,
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(width: 10.w),
          Icon(
            Icons.more_vert_rounded,
            color: AppColors.subtitleTextColor,
            size: 20.sp,
          ),
          SizedBox(width: 4.w),
        ],
      ),
      body: SafeArea(
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 30.h),
          children: [
            _profileHeader(ref),
            SizedBox(height: 13.h),
            _metrics(ref),
            SizedBox(height: 18.h),
            _sectionTitle(
              ref,
              ref.watchTr(AppStrings.latestClassReportTitle),
              trailing: '24 Oct · Sesión #18',
            ),
            SizedBox(height: 8.h),
            _latestReport(ref),
            SizedBox(height: 16.h),
            _sectionTitle(
              ref,
              ref.watchTr(AppStrings.activeHomeworkTitle),
              trailingWidget: _reviewDueTag(ref),
            ),
            SizedBox(height: 8.h),
            _homeworkCard(ref),
            SizedBox(height: 17.h),
            _sectionTitle(
              ref,
              ref.watchTr(AppStrings.facultyNoteTitle),
              trailing: 'Dra. S. Jenkins',
            ),
            SizedBox(height: 8.h),
            _facultyNoteWidget(facultyNotes),
            SizedBox(height: 8.h),
            _addNoteButton(context, ref),
            Gap(20.h),
          ],
        ),
      ),
    );
  }

  Widget _profileHeader(WidgetRef ref) {
    return Row(
      children: [
        Stack(
          children: [
            Container(
              width: 52.w,
              height: 52.w,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xffe8edf5),
              ),
              child: Center(
                child: Text(
                  'LR',
                  style: TxtStyle.titleLarge(
                    color: AppColors.primaryDark,
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                width: 14.w,
                height: 14.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xff18b86b),
                  border: Border.all(color: Colors.white, width: 2),
                ),
              ),
            ),
          ],
        ),
        SizedBox(width: 13.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Lucas Rivera',
                style: TxtStyle.titleLarge(
                  color: AppColors.text,
                  fontSize: 22.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                '${ref.watchTr(AppStrings.bachillerato1)} • ${ref.watchTr(AppStrings.groupA)} • Pupitre 04',
                style: TxtStyle.bodyMedium(
                  color: AppColors.subtitleTextColor,
                  fontSize: 14.5.sp,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _metrics(WidgetRef ref) {
    return Row(
      children: [
        Expanded(
          child: _metricCard(
            ref,
            label: ref.watchTr(AppStrings.attendance).toUpperCase(),
            value: '96%',
            accentColor: const Color(0xff18b86b),
          ),
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: _metricCard(
            ref,
            label: ref.watchTr(AppStrings.absent).toUpperCase(),
            value: '1',
            accentColor: AppColors.primaryDark,
          ),
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: _metricCard(
            ref,
            label: ref.watchTr(AppStrings.late).toUpperCase(),
            value: '0',
            accentColor: AppColors.subtitleTextColor,
          ),
        ),
      ],
    );
  }

  Widget _metricCard(
    WidgetRef ref, {
    required String label,
    required String value,
    required Color accentColor,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(7.r),
        border: Border.all(color: AppColors.backgroundsLinesColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TxtStyle.bodyMedium(
              color: AppColors.subtitleTextColor,
              fontSize: 13.sp,
              fontWeight: FontWeight.w700,
              letterSpacing: .3,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            value,
            style: TxtStyle.titleLarge(
              color: accentColor,
              fontSize: 24.sp,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(
    WidgetRef ref,
    String title, {
    String? trailing,
    Widget? trailingWidget,
  }) {
    return Row(
      children: [
        Text(
          title,
          style: TxtStyle.titleLarge(
            color: AppColors.text,
            fontSize: 17.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
        const Spacer(),
        if (trailingWidget != null)
          trailingWidget
        else if (trailing != null)
          Text(
            trailing,
            style: TxtStyle.bodyMedium(
              color: AppColors.subtitleTextColor,
              fontSize: 14.sp,
            ),
          ),
      ],
    );
  }

  Widget _latestReport(WidgetRef ref) {
    return Container(
      padding: EdgeInsets.all(11.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(7.r),
        border: Border.all(color: AppColors.backgroundsLinesColor),
      ),
      child: RichText(
        text: TextSpan(
          style: TxtStyle.bodyMedium(
            color: AppColors.subtitleTextColor,
            fontSize: 15.5.sp,
            height: 1.45,
          ),
          children: [
            TextSpan(
              text: 'Demostración en pizarra: ',
              style: TxtStyle.bodyMedium(
                color: AppColors.primaryDark,
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
            const TextSpan(
              text:
                  'Gran esfuerzo. Dominó la regla de la cadena en la pizarra con excelente actitud.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _reviewDueTag(WidgetRef ref) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: const Color(0xffffe9c7),
        borderRadius: BorderRadius.circular(9.r),
      ),
      child: Text(
        ref.watchTr(AppStrings.reviewPending),
        style: TxtStyle.bodyMedium(
          color: const Color(0xffdf8a00),
          fontSize: 14.5.sp,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _homeworkCard(WidgetRef ref) {
    return Container(
      padding: EdgeInsets.all(11.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(7.r),
        border: Border.all(color: AppColors.backgroundsLinesColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Relación de ejercicios 4: Derivación implícita',
            style: TxtStyle.titleLarge(
              color: AppColors.text,
              fontSize: 16.5.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            'Ejercicios 12–25 • Entrega en cuaderno',
            style: TxtStyle.bodyMedium(
              color: AppColors.subtitleTextColor,
              fontSize: 16.sp,
            ),
          ),
          SizedBox(height: 9.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.calendar_today_outlined,
                    size: 11.sp,
                    color: AppColors.subtitleTextColor,
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    'Entrega: 29 Oct',
                    style: TxtStyle.bodyMedium(
                      color: AppColors.subtitleTextColor,
                      fontSize: 15.5.sp,
                    ),
                  ),
                ],
              ),
              Gap(10.w),
              Flexible(
                child: Text(
                  'Copia en mano',
                  style: TxtStyle.bodyMedium(
                    color: AppColors.primaryDark,
                    fontSize: 15.5.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _facultyNoteWidget(List<String> facultyNotes) {
    const defaultNote =
        'Demuestra un sólido entendimiento conceptual en los ejercicios de pizarra. '
        'Ayuda activamente a sus compañeros del Grupo A.';

    final notes = [defaultNote, ...facultyNotes];

    return Column(
      children: notes.map((note) {
        return Container(
          width: double.infinity,
          margin: EdgeInsets.only(bottom: 8.h),
          padding: EdgeInsets.all(11.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(7.r),
            border: Border.all(color: AppColors.backgroundsLinesColor),
          ),
          child: Text(
            '"$note"',
            style: TxtStyle.bodyMedium(
              color: AppColors.subtitleTextColor,
              fontSize: 16.sp,
              height: 1.5,
              fontStyle: FontStyle.italic,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _addNoteButton(BuildContext context, WidgetRef ref) {
    return OutlinedButton(
      onPressed: () => _showAddNoteBottomSheet(context, ref),
      style: OutlinedButton.styleFrom(
        minimumSize: Size(double.infinity, 38.h),
        side: BorderSide(color: AppColors.backgroundsLinesColor),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7.r)),
      ),
      child: Text(
        ref.watchTr(AppStrings.addNoteBtn),
        style: TxtStyle.titleLarge(
          color: AppColors.primaryDark,
          fontSize: 17.sp,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Future<void> _showAddNoteBottomSheet(BuildContext context, WidgetRef ref) async {
    final note = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useSafeArea: true,
      builder: (_) {
        return const _AddNoteBottomSheet();
      },
    );

    if (note != null && note.trim().isNotEmpty) {
      ref.read(teacherFacultyNotesProvider.notifier).addNote(note.trim());
    }
  }
}

class _AddNoteBottomSheet extends ConsumerStatefulWidget {
  const _AddNoteBottomSheet();

  @override
  ConsumerState<_AddNoteBottomSheet> createState() =>
      _AddNoteBottomSheetState();
}

class _AddNoteBottomSheetState extends ConsumerState<_AddNoteBottomSheet> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _saveNote() {
    final note = _controller.text.trim();
    if (note.isEmpty) {
      return;
    }
    Navigator.of(context).pop(note);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.fromLTRB(16.w, 20.h, 16.w, 16.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(18.r)),
        ),
        child: SingleChildScrollView(
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ref.watchTr(AppStrings.addNoteTitle),
                  style: TxtStyle.titleLarge(
                    color: AppColors.text,
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 16.h),
                TextField(
                  controller: _controller,
                  maxLines: 5,
                  autofocus: true,
                  textInputAction: TextInputAction.newline,
                  decoration: InputDecoration(
                    hintText: ref.watchTr(AppStrings.writeNoteHint),
                    hintStyle: TxtStyle.bodyMedium(
                      color: AppColors.subtitleTextColor,
                      fontSize: 15.sp,
                    ),
                    filled: true,
                    fillColor: AppColors.softBackground,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.r),
                      borderSide: BorderSide(
                        color: AppColors.backgroundsLinesColor,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.r),
                      borderSide: BorderSide(
                        color: AppColors.backgroundsLinesColor,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.r),
                      borderSide: BorderSide(color: AppColors.primaryDark),
                    ),
                  ),
                ),
                SizedBox(height: 16.h),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _saveNote,
                    child: Text(
                      ref.watchTr(AppStrings.saveNoteBtn),
                      style: TxtStyle.titleLarge(
                        color: Colors.white,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
