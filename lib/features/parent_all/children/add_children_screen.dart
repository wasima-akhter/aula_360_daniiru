import '../../share/export/screen_export.dart';
import '../helper/parent_widgets.dart';
import '../presentation/controllers/parent_children_controller.dart';

/// ===============================================================
/// 4. ADD CHILD / MATRÍCULA DE ESTUDIANTE
/// ===============================================================

class AddChildScreen extends ConsumerStatefulWidget {
  const AddChildScreen({super.key});

  @override
  ConsumerState<AddChildScreen> createState() => _AddChildScreenState();
}

class _AddChildScreenState extends ConsumerState<AddChildScreen> {
  final _formKey = GlobalKey<FormState>();

  final fullNameController = TextEditingController();
  final dobController = TextEditingController();
  final studentIdController = TextEditingController();

  String gradeKey = AppStrings.primaria2;
  String genderKey = 'male';

  @override
  void dispose() {
    fullNameController.dispose();
    dobController.dispose();
    studentIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F7FC),
      resizeToAvoidBottomInset: true,
      appBar: simpleAppBar(context, ref.watchTr(AppStrings.addChildTitle)),
      body: SafeArea(
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.fromLTRB(14.w, 14.h, 14.w, 30.h + bottomInset),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _newEnrollmentBadge(),
                SizedBox(height: 10.h),
                Text(
                  ref.watchTr(AppStrings.studentInfoTitle),
                  style: TxtStyle.titleLarge(
                    color: AppColors.text,
                    fontSize: 19.sp,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  ref.watchTr(AppStrings.studentInfoDesc),
                  style: TxtStyle.titleLarge(
                    color: AppColors.subtitleTextColor,
                    fontSize: 15.5.sp,
                    height: 1.4,
                  ),
                ),
                SizedBox(height: 15.h),
                _parentAccountCard(),
                SizedBox(height: 13.h),
                _photoUploader(),
                SizedBox(height: 15.h),
                _requiredField(
                  ref.watchTr(AppStrings.fieldFullName),
                  fullNameController,
                  Icons.person_outline,
                ),
                _dateField(),
                _gradeDropdown(),
                _genderSelector(),
                _optionalIdField(),
                _connectionNotice(),
                SizedBox(height: 15.h),
                _saveChildButton(),
                SizedBox(height: 7.h),
                Center(
                  child: TextButton(
                    onPressed: () => context.pop(),
                    child: Text(
                      ref.watchTr(AppStrings.cancel),
                      style: TxtStyle.titleLarge(
                        color: AppColors.subtitleTextColor,
                        fontSize: 15.5.sp,
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

  Widget _newEnrollmentBadge() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: AppColors.blueSoft,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Text(
        '• ${ref.watchTr(AppStrings.newStudentEnrollment).toUpperCase()}',
        style: TxtStyle.titleLarge(
          color: AppColors.primaryDark,
          fontSize: 14.sp,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _parentAccountCard() {
    return Container(
      padding: EdgeInsets.all(11.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 31.w,
            height: 31.w,
            decoration: BoxDecoration(
              color: AppColors.blueSoft,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              'EV',
              style: TxtStyle.titleLarge(
                color: AppColors.primaryDark,
                fontSize: 14.sp,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          SizedBox(width: 9.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ref.watchTr(AppStrings.parentAccount).toUpperCase(),
                  style: TxtStyle.titleLarge(
                    color: AppColors.subtitleTextColor,
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  'Eleanor Vance',
                  style: TxtStyle.titleLarge(
                    color: AppColors.text,
                    fontSize: 14.5.sp,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 3.h),
            decoration: BoxDecoration(
              color: AppColors.blueSoft,
              borderRadius: BorderRadius.circular(9.r),
            ),
            child: Text(
              ref.watchTr(AppStrings.verified),
              style: TxtStyle.titleLarge(
                color: AppColors.primaryDark,
                fontSize: 14.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _photoUploader() {
    return InkWell(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              ref.watchTr(AppStrings.uploadPhotoOptional),
              style: TxtStyle.titleLarge(fontSize: 14.sp, color: Colors.white),
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      borderRadius: BorderRadius.circular(8.r),
      child: Container(
        width: double.infinity,
        height: 105.h,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 38.w,
              height: 38.w,
              decoration: BoxDecoration(
                color: AppColors.blueSoft,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.add_a_photo_outlined,
                color: AppColors.primaryDark,
                size: 20.sp,
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              ref.watchTr(AppStrings.uploadPhotoOptional),
              style: TxtStyle.titleLarge(
                color: AppColors.primaryDark,
                fontSize: 15.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              ref.watchTr(AppStrings.uploadPhotoHint),
              style: TxtStyle.titleLarge(
                color: AppColors.subtitleTextColor,
                fontSize: 14.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _requiredField(
    String label,
    TextEditingController controller,
    IconData icon,
  ) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _label(label, requiredField: true),
          SizedBox(height: 5.h),
          TextFormField(
            controller: controller,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return '$label ${ref.watchTr(AppStrings.fieldRequired)}';
              }
              return null;
            },
            style: TxtStyle.titleLarge(color: AppColors.text, fontSize: 14.sp),
            decoration: _inputDecoration(icon),
          ),
        ],
      ),
    );
  }

  Widget _dateField() {
    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _label(ref.watchTr(AppStrings.dateOfBirth), requiredField: true),
          SizedBox(height: 5.h),
          TextFormField(
            controller: dobController,
            readOnly: true,
            onTap: _selectDate,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return '${ref.watchTr(AppStrings.dateOfBirth)} ${ref.watchTr(AppStrings.fieldRequired)}';
              }
              return null;
            },
            style: TxtStyle.titleLarge(color: AppColors.text, fontSize: 14.sp),
            decoration: _inputDecoration(Icons.calendar_today_outlined),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      initialDate: DateTime(2016),
    );

    if (picked != null) {
      setState(() {
        dobController.text =
            '${picked.day.toString().padLeft(2, '0')}/'
            '${picked.month.toString().padLeft(2, '0')}/'
            '${picked.year}';
      });
    }
  }

  Widget _gradeDropdown() {
    const gradesList = [
      AppStrings.primaria1,
      AppStrings.primaria2,
      AppStrings.primaria3,
      AppStrings.primaria4,
      AppStrings.primaria5,
      AppStrings.primaria6,
      AppStrings.eso1,
      AppStrings.eso2,
      AppStrings.eso3,
      AppStrings.eso4,
      AppStrings.bachillerato1,
      AppStrings.bachillerato2,
    ];

    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _label(ref.watchTr(AppStrings.gradeLevel), requiredField: true),
          SizedBox(height: 5.h),
          DropdownButtonFormField<String>(
            initialValue: gradeKey,
            decoration: _inputDecoration(Icons.school_outlined),
            items: gradesList
                .map(
                  (key) => DropdownMenuItem(
                    value: key,
                    child: Text(ref.watchTr(key)),
                  ),
                )
                .toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() => gradeKey = value);
              }
            },
            style: TxtStyle.titleLarge(color: AppColors.text, fontSize: 15.sp),
          ),
        ],
      ),
    );
  }

  Widget _genderSelector() {
    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _label(ref.watchTr(AppStrings.gender), requiredField: true),
          SizedBox(height: 5.h),
          Container(
            height: 42.h,
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: AppColors.softSlateBgColor,
              borderRadius: BorderRadius.circular(7.r),
            ),
            child: Row(
              children: [
                _genderOption('female', ref.watchTr(AppStrings.genderFemale)),
                _genderOption('male', ref.watchTr(AppStrings.genderMale)),
                _genderOption('other', ref.watchTr(AppStrings.genderPreferNot)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _genderOption(String key, String label) {
    final selected = genderKey == key;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => genderKey = key),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(5.r),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: .04),
                      blurRadius: 3,
                    ),
                  ]
                : null,
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TxtStyle.titleLarge(
              color: selected
                  ? AppColors.primaryDark
                  : AppColors.subtitleTextColor,
              fontSize: 13.5.sp,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _optionalIdField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label(ref.watchTr(AppStrings.studentId), requiredField: false),
        SizedBox(height: 2.h),
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            ref.watchTr(AppStrings.providedByAcademy),
            style: TxtStyle.titleLarge(
              color: AppColors.subtitleTextColor,
              fontSize: 14.sp,
            ),
          ),
        ),
        SizedBox(height: 4.h),
        TextFormField(
          controller: studentIdController,
          style: TxtStyle.titleLarge(color: AppColors.text, fontSize: 14.sp),
          decoration: _inputDecoration(Icons.badge_outlined),
        ),
        SizedBox(height: 12.h),
      ],
    );
  }

  Widget _connectionNotice() {
    return Container(
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(
        color: AppColors.blueSoft,
        borderRadius: BorderRadius.circular(7.r),
      ),
      child: Row(
        children: [
          Icon(
            Icons.check_circle_outline,
            color: AppColors.emeraldGreenColor,
            size: 17.sp,
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              ref.watchTr(AppStrings.studentConnectionNotice),
              style: TxtStyle.titleLarge(
                color: AppColors.subtitleTextColor,
                fontSize: 14.sp,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _saveChildButton() {
    final isSaving = ref.watch(parentChildrenControllerProvider).isLoading;
    return SizedBox(
      width: double.infinity,
      child: AulaPrimaryButton(
        text: ref.watchTr(AppStrings.saveChild),
        isLoading: isSaving,
        leading: Icon(Icons.check, color: Colors.white, size: 20.sp),
        trailing: const SizedBox.shrink(),
        backgroundColor: AppColors.primaryDark,
        onTap: _saveChild,
      ),
    );
  }

  void _saveChild() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final parentTeacher =
        ref
            .read(languageProvider)
            .valueOrNull
            ?.tr(AppStrings.assignedAfterEnrollment) ??
        'Asignado tras matrícula';
    final selectedGrade =
        ref.read(languageProvider).valueOrNull?.tr(gradeKey) ??
        ref.watchTr(gradeKey);
    await ref
        .read(parentChildrenControllerProvider.notifier)
        .addChild(
          name: fullNameController.text.trim(),
          grade: selectedGrade,
          room: 'Aula 2A',
          parentTeacher: parentTeacher,
        );

    if (mounted) {
      context.pop();
    }
  }

  Widget _label(String text, {required bool requiredField}) {
    return RichText(
      text: TextSpan(
        text: text,
        style: TxtStyle.titleLarge(
          color: AppColors.labelTextColor,
          fontSize: 15.sp,
          fontWeight: FontWeight.w700,
        ),
        children: [
          if (requiredField)
            TextSpan(
              text: ' *',
              style: TxtStyle.titleLarge(
                color: AppColors.error,
                fontSize: 15.sp,
              ),
            ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(IconData icon) {
    return InputDecoration(
      prefixIcon: Icon(icon, size: 17.sp, color: AppColors.subtitleTextColor),
      filled: true,
      fillColor: Colors.white,
      contentPadding: EdgeInsets.symmetric(horizontal: 11.w, vertical: 12.h),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(7.r),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(7.r),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(7.r),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.3),
      ),
    );
  }
}
