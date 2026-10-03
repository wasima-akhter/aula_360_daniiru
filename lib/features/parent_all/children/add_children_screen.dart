import '../../share/export/screen_export.dart';
import '../helper/parent_models.dart';
import '../helper/parent_widgets.dart';

/// ===============================================================
/// 4. ADD CHILD
/// ===============================================================

class AddChildScreen extends StatefulWidget {
  const AddChildScreen({super.key});

  @override
  State<AddChildScreen> createState() => _AddChildScreenState();
}

class _AddChildScreenState extends State<AddChildScreen> {
  final _formKey = GlobalKey<FormState>();

  final fullNameController = TextEditingController();
  final dobController = TextEditingController();
  final studentIdController = TextEditingController();

  String grade = 'Grade 2 (Primary)';
  String gender = 'Male';

  @override
  void dispose() {
    fullNameController.dispose();
    dobController.dispose();
    studentIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F7FC),
      appBar: simpleAppBar(context, 'Add Child'),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.fromLTRB(14.w, 14.h, 14.w, 30.h),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _newEnrollmentBadge(),
                SizedBox(height: 10.h),
                Text(
                  'Student Information',
                  style: TxtStyle.titleLarge(
                    color: AppColors.text,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'Enter basic details to connect your child to your academy parent account.',
                  style: TxtStyle.titleLarge(
                    color: AppColors.subtitleTextColor,
                    fontSize: 12.5.sp,
                    height: 1.4,
                  ),
                ),
                SizedBox(height: 15.h),
                _parentAccountCard(),
                SizedBox(height: 13.h),
                _photoUploader(),
                SizedBox(height: 15.h),
                _requiredField(
                  'Full Name',
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
                      'Cancel',
                      style: TxtStyle.titleLarge(
                        color: AppColors.subtitleTextColor,
                        fontSize: 12.5.sp,
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
        '• NEW STUDENT ENROLLMENT',
        style: TxtStyle.titleLarge(
          color: AppColors.primaryDark,
          fontSize: 12.sp,
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
              'ER',
              style: TxtStyle.titleLarge(
                color: AppColors.primaryDark,
                fontSize: 11.sp,
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
                  'PARENT ACCOUNT',
                  style: TxtStyle.titleLarge(
                    color: AppColors.subtitleTextColor,
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  'Eleanor Rivera',
                  style: TxtStyle.titleLarge(
                    color: AppColors.text,
                    fontSize: 11.5.sp,
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
              'Verified',
              style: TxtStyle.titleLarge(
                color: AppColors.primaryDark,
                fontSize: 12.sp,
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
              'Photo picker opened.',
              style: TxtStyle.titleLarge(fontSize: 11.sp, color: Colors.white),
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
              'Upload Photo (Optional)',
              style: TxtStyle.titleLarge(
                color: AppColors.primaryDark,
                fontSize: 12.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              'JPG or PNG up to 5MB',
              style: TxtStyle.titleLarge(
                color: AppColors.subtitleTextColor,
                fontSize: 12.sp,
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
                return '$label is required';
              }
              return null;
            },
            style: TxtStyle.titleLarge(color: AppColors.text, fontSize: 11.sp),
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
          _label('Date of Birth', requiredField: true),
          SizedBox(height: 5.h),
          TextFormField(
            controller: dobController,
            readOnly: true,
            onTap: _selectDate,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Date of Birth is required';
              }
              return null;
            },
            style: TxtStyle.titleLarge(color: AppColors.text, fontSize: 11.sp),
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
            '${picked.month.toString().padLeft(2, '0')}/'
            '${picked.day.toString().padLeft(2, '0')}/'
            '${picked.year}';
      });
    }
  }

  Widget _gradeDropdown() {
    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _label('Grade / Level', requiredField: true),
          SizedBox(height: 5.h),
          DropdownButtonFormField<String>(
            initialValue: grade,
            decoration: _inputDecoration(Icons.school_outlined),
            items: const [
              DropdownMenuItem(
                value: 'Grade 1 (Primary)',
                child: Text('Grade 1 (Primary)'),
              ),
              DropdownMenuItem(
                value: 'Grade 2 (Primary)',
                child: Text('Grade 2 (Primary)'),
              ),
              DropdownMenuItem(
                value: 'Grade 3 (Primary)',
                child: Text('Grade 3 (Primary)'),
              ),
              DropdownMenuItem(value: 'Grade 8', child: Text('Grade 8')),
            ],
            onChanged: (value) {
              if (value != null) {
                setState(() => grade = value);
              }
            },
            style: TxtStyle.titleLarge(color: AppColors.text, fontSize: 13.sp),
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
          _label('Gender', requiredField: true),
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
                _genderOption('Female'),
                _genderOption('Male'),
                _genderOption('Prefer not to say'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _genderOption(String value) {
    final selected = gender == value;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => gender = value),
        child: Container(
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
            value,
            textAlign: TextAlign.center,
            style: TxtStyle.titleLarge(
              color: selected
                  ? AppColors.primaryDark
                  : AppColors.subtitleTextColor,
              fontSize: 12.sp,
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
        _label('Student ID', requiredField: false),
        SizedBox(height: 2.h),
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            'Provided by academy',
            style: TxtStyle.titleLarge(
              color: AppColors.subtitleTextColor,
              fontSize: 12.sp,
            ),
          ),
        ),
        SizedBox(height: 4.h),
        TextFormField(
          controller: studentIdController,
          style: TxtStyle.titleLarge(color: AppColors.text, fontSize: 11.sp),
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
              'Student record connects directly to your parent dashboard upon confirmation.',
              style: TxtStyle.titleLarge(
                color: AppColors.subtitleTextColor,
                fontSize: 12.sp,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _saveChildButton() {
    return SizedBox(
      width: double.infinity,
      height: 44.h,
      child: ElevatedButton(
        onPressed: _saveChild,
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: AppColors.primaryDark,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(7.r),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check, color: Colors.white, size: 15.sp),
            SizedBox(width: 5.w),
            Text(
              'Save Child',
              style: TxtStyle.titleLarge(
                color: Colors.white,
                fontSize: 12.sp,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _saveChild() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final newChild = ChildModel(
      id: studentIdController.text.trim().isEmpty
          ? '#STU-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}'
          : studentIdController.text.trim(),
      name: fullNameController.text.trim(),
      grade: grade,
      room: 'Room 2A',
      imageUrl:
          'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=400',
      parentTeacher: 'Assigned after enrollment',
      attendance: 100,
      present: 0,
      absent: 0,
      late: 0,
    );

    context.pop(newChild);
  }

  Widget _label(String text, {required bool requiredField}) {
    return RichText(
      text: TextSpan(
        text: text,
        style: TxtStyle.titleLarge(
          color: AppColors.labelTextColor,
          fontSize: 13.sp,
          fontWeight: FontWeight.w700,
        ),
        children: [
          if (requiredField)
            TextSpan(
              text: ' *',
              style: TxtStyle.titleLarge(
                color: AppColors.error,
                fontSize: 13.sp,
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
