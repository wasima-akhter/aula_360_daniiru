import '../../parent_all/helper/parent_home_helper.dart';
import '../../share/export/screen_export.dart';
import '../helper/teacher_enums.dart';
import '../presentation/controllers/teacher_reports_controller.dart';

/// ===============================================================
/// 2. POST CLASS REPORT SCREEN
/// ===============================================================

class TeacherPostClassReportScreen extends ConsumerStatefulWidget {
  const TeacherPostClassReportScreen({super.key});

  @override
  ConsumerState<TeacherPostClassReportScreen> createState() =>
      _TeacherPostClassReportScreenState();
}

class _TeacherPostClassReportScreenState
    extends ConsumerState<TeacherPostClassReportScreen> {
  late final TextEditingController homeworkController;
  late final TextEditingController notesController;

  @override
  void initState() {
    super.initState();
    final formState = ref.read(teacherReportFormControllerProvider);
    homeworkController = TextEditingController(text: formState.homework);
    notesController = TextEditingController(text: formState.notes);
  }

  @override
  void dispose() {
    homeworkController.dispose();
    notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(teacherReportFormControllerProvider);
    final formController = ref.read(teacherReportFormControllerProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AulaAppBar(title: ref.watchTr(AppStrings.postClassReportTitle), showBack: true),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.fromLTRB(16.w, 19.h, 16.w, 30.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _classHeader(),
              SizedBox(height: 24.h),
              _sectionLabel(ref.watchTr(AppStrings.contentDeliveredTitle)),
              SizedBox(height: 8.h),
              _textCard(
                'Regla de la cadena y derivación implícita; ejercicios\n'
                'prácticos resueltos en pizarra.',
              ),
              SizedBox(height: 19.h),
              Row(
                children: [
                  _sectionLabel(ref.watchTr(AppStrings.assignedTasksTitle)),
                  const Spacer(),
                  Text(
                    ref.watchTr(AppStrings.optional),
                    style: TxtStyle.bodyMedium(
                      color: AppColors.subtitleTextColor,
                      fontSize: 13.sp,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8.h),
              _editableTextCard(
                controller: homeworkController,
                hint: 'Relación 4: Ejercicios 12–25 (Entrega próximo martes)',
                onChanged: formController.setHomework,
              ),
              SizedBox(height: 20.h),
              _selectionSection(
                title: ref.watchTr(AppStrings.conductAndAttitudeTitle),
                value: _conductLabel(formState.conduct),
                children: [
                  _choiceButton(
                    label: ref.watchTr(AppStrings.conductNeedsAttention),
                    selected: formState.conduct == StudentConduct.needsAttention,
                    onTap: () => formController.setConduct(StudentConduct.needsAttention),
                  ),
                  _choiceButton(
                    label: ref.watchTr(AppStrings.conductSatisfactory),
                    selected: formState.conduct == StudentConduct.satisfactory,
                    onTap: () => formController.setConduct(StudentConduct.satisfactory),
                  ),
                  _choiceButton(
                    label: ref.watchTr(AppStrings.conductExcellent),
                    selected: formState.conduct == StudentConduct.excellent,
                    onTap: () => formController.setConduct(StudentConduct.excellent),
                  ),
                ],
              ),
              SizedBox(height: 20.h),
              _selectionSection(
                title: ref.watchTr(AppStrings.effortAndDedicationTitle),
                value: _effortLabel(formState.effort),
                children: [
                  _choiceButton(
                    label: ref.watchTr(AppStrings.effortModerate),
                    selected: formState.effort == WorkEffort.moderate,
                    onTap: () => formController.setEffort(WorkEffort.moderate),
                  ),
                  _choiceButton(
                    label: ref.watchTr(AppStrings.effortAdequate),
                    selected: formState.effort == WorkEffort.onTrack,
                    onTap: () => formController.setEffort(WorkEffort.onTrack),
                  ),
                  _choiceButton(
                    label: ref.watchTr(AppStrings.effortHighPerformance),
                    selected: formState.effort == WorkEffort.highEffort,
                    onTap: () => formController.setEffort(WorkEffort.highEffort),
                  ),
                ],
              ),
              SizedBox(height: 20.h),
              Row(
                children: [
                  _sectionLabel(ref.watchTr(AppStrings.quickNotesTitle)),
                  const Spacer(),
                  Text(
                    ref.watchTr(AppStrings.optional),
                    style: TxtStyle.bodyMedium(
                      color: AppColors.subtitleTextColor,
                      fontSize: 13.sp,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8.h),
              _notesField(onChanged: formController.setNotes),
              SizedBox(height: 32.h),
              SizedBox(
                width: double.infinity,
                child: AulaPrimaryButton(
                  onTap: () {
                    context.push(RoutePath.teacherReportSubmitted);
                  },
                  text: ref.watchTr(AppStrings.sendReportBtn),
                  trailing: Icon(
                    Icons.arrow_forward_rounded,
                    color: Colors.white,
                    size: 18.sp,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _classHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'GRUPO A • ${ref.watchTr(AppStrings.bachillerato1).toUpperCase()} • ${ref.watchTr(AppStrings.aula2).toUpperCase()}',
          style: TxtStyle.labelLarge(
            color: AppColors.subtitleTextColor,
            fontSize: 14.sp,
            fontWeight: FontWeight.w700,
            letterSpacing: .5,
          ),
        ),
        SizedBox(height: 7.h),
        Text(
          '${ref.watchTr(AppStrings.subjectMath)} Avanzadas (Cálculo y Álgebra)',
          style: TxtStyle.titleLarge(
            color: AppColors.text,
            fontSize: 23.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: 5.h),
        Text(
          'Jue, 24 Oct • Dra. Sarah Jenkins',
          style: TxtStyle.bodyMedium(
            color: AppColors.subtitleTextColor,
            fontSize: 16.sp,
          ),
        ),
      ],
    );
  }

  Widget _sectionLabel(String text) {
    return Text(
      text,
      style: TxtStyle.labelLarge(
        color: AppColors.text,
        fontSize: 17.sp,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _textCard(String text) {
    return Container(
      width: double.infinity,
      height: 80.h,
      padding: EdgeInsets.all(11.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(7.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        text,
        style: TxtStyle.bodyMedium(
          color: AppColors.subtitleTextColor,
          fontSize: 14.5.sp,
          height: 1.45,
        ),
      ),
    );
  }

  Widget _editableTextCard({
    required TextEditingController controller,
    required String hint,
    required ValueChanged<String> onChanged,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 58.h,
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        maxLines: 2,
        style: TxtStyle.bodyMedium(
          color: AppColors.subtitleTextColor,
          fontSize: 14.5.sp,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TxtStyle.bodyMedium(
            color: AppColors.subtitleTextColor,
            fontSize: 14.5.sp,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            vertical: 10.h,
            horizontal: 11.w,
          ),
        ),
      ),
    );
  }

  Widget _selectionSection({
    required String title,
    required String value,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _sectionLabel(title),
            const Spacer(),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TxtStyle.labelLarge(
                color: AppColors.grayTertiaryTextColor,
                fontSize: 13.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        Wrap(
          runSpacing: 8.w,
          children: [
            for (int i = 0; i < children.length; i++) ...[
              children[i],
              if (i != children.length - 1) SizedBox(width: 7.w),
            ],
          ],
        ),
      ],
    );
  }

  Widget _choiceButton({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            height: 31.h,
            alignment: Alignment.center,
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            decoration: BoxDecoration(
              color: selected ? AppColors.primaryColor : Colors.white,
              borderRadius: BorderRadius.circular(7.r),
              border: Border.all(
                color: selected ? AppColors.primaryColor : AppColors.border,
              ),
            ),
            child: Text(
              label,
              style: TxtStyle.labelLarge(
                color: selected ? Colors.white : AppColors.subtitleTextColor,
                fontSize: 14.5.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _notesField({required ValueChanged<String> onChanged}) {
    return SizedBox(
      width: double.infinity,
      height: 62.h,
      child: TextField(
        controller: notesController,
        onChanged: onChanged,
        maxLines: 3,
        style: TxtStyle.bodyMedium(color: AppColors.text, fontSize: 14.5.sp),
        decoration: InputDecoration(
          hintText: 'Observaciones adicionales o seguimiento...',
          hintStyle: TxtStyle.bodyMedium(
            color: AppColors.subtitleTextColor,
            fontSize: 14.5.sp,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            vertical: 10.h,
            horizontal: 11.w,
          ),
        ),
      ),
    );
  }

  String _conductLabel(StudentConduct value) {
    switch (value) {
      case StudentConduct.needsAttention:
        return ref.watchTr(AppStrings.conductNeedsAttention);
      case StudentConduct.satisfactory:
        return ref.watchTr(AppStrings.conductSatisfactory);
      case StudentConduct.excellent:
        return ref.watchTr(AppStrings.conductExcellent);
    }
  }

  String _effortLabel(WorkEffort value) {
    switch (value) {
      case WorkEffort.moderate:
        return ref.watchTr(AppStrings.effortModerate);
      case WorkEffort.onTrack:
        return ref.watchTr(AppStrings.effortAdequate);
      case WorkEffort.highEffort:
        return ref.watchTr(AppStrings.effortHighPerformance);
    }
  }
}
