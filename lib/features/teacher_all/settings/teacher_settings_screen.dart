import '../../share/export/screen_export.dart';

/// ===============================================================
/// SETTINGS
/// ===============================================================

class TeacherSettingsScreen extends StatefulWidget {
  const TeacherSettingsScreen({super.key});

  @override
  State<TeacherSettingsScreen> createState() => _TeacherSettingsScreenState();
}

class _TeacherSettingsScreenState extends State<TeacherSettingsScreen> {
  String language = 'English (US)';

  bool classReminders = true;
  bool parentMessages = true;
  bool postClassReports = true;
  bool biometricAccess = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F7FC),
      appBar: _appBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.fromLTRB(14.w, 15.h, 14.w, 30.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _breadcrumb(),

              SizedBox(height: 22.h),

              _sectionLabel('LANGUAGE'),
              SizedBox(height: 8.h),

              _languageCard(),

              SizedBox(height: 22.h),

              _sectionLabel('NOTIFICATIONS'),
              SizedBox(height: 8.h),

              _notificationCard(),

              SizedBox(height: 22.h),

              _sectionLabel('ACCOUNT & SECURITY'),
              SizedBox(height: 8.h),

              _securityCard(),
            ],
          ),
        ),
      ),
    );
  }

  // ===============================================================
  // APP BAR
  // ===============================================================

  PreferredSizeWidget _appBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        onPressed: () => context.pop(),
        icon: Icon(Icons.arrow_back, color: AppColors.primaryDark, size: 21.sp),
      ),
      title: Text(
        'Settings',
        style: TxtStyle.titleLarge(
          color: AppColors.primaryDark,
          fontSize: 14.sp,
          fontWeight: FontWeight.w800,
        ),
      ),
      bottom: PreferredSize(
        preferredSize: Size.fromHeight(1.h),
        child: Container(height: 1, color: AppColors.backgroundsLinesColor),
      ),
    );
  }

  // ===============================================================
  // BREADCRUMB
  // ===============================================================

  Widget _breadcrumb() {
    return Row(
      children: [
        GestureDetector(
          onTap: () => context.pop(),
          child: Text(
            'Profile',
            style: TxtStyle.titleLarge(
              color: AppColors.subtitleTextColor,
              fontSize: 13.sp,
            ),
          ),
        ),

        Padding(
          padding: EdgeInsets.symmetric(horizontal: 5.w),
          child: Text(
            '›',
            style: TxtStyle.titleLarge(
              color: AppColors.hintTextColor,
              fontSize: 13.sp,
            ),
          ),
        ),

        Text(
          'Settings',
          style: TxtStyle.titleLarge(
            color: AppColors.primaryDark,
            fontSize: 13.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  // ===============================================================
  // LANGUAGE
  // ===============================================================

  Widget _languageCard() {
    return _card(
      child: _settingsRow(
        icon: Icons.language_outlined,
        title: 'Display Language',
        subtitle: 'Choose the language used throughout the portal',
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              language,
              style: TxtStyle.titleLarge(
                color: AppColors.primaryDark,
                fontSize: 11.5.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(width: 3.w),
            Icon(
              Icons.chevron_right,
              color: AppColors.subtitleTextColor,
              size: 18.sp,
            ),
          ],
        ),
        onTap: _showLanguagePicker,
      ),
    );
  }

  Future<void> _showLanguagePicker() async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.white,
      showDragHandle: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18.r)),
      ),
      builder: (context) {
        final languages = ['English (US)', 'English (UK)', 'Spanish'];

        return SafeArea(
          child: Padding(
            padding: EdgeInsets.only(bottom: 15.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 18.w,
                    vertical: 5.h,
                  ),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Select Language',
                      style: TxtStyle.titleLarge(
                        color: AppColors.text,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
                ...languages.map(
                  (item) => RadioListTile<String>(
                    value: item,
                    groupValue: language,
                    activeColor: AppColors.primary,
                    title: Text(
                      item,
                      style: TxtStyle.titleLarge(fontSize: 13.sp),
                    ),
                    onChanged: (value) {
                      if (value != null) {
                        Navigator.pop(context, value);
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (!mounted || selected == null) return;

    setState(() {
      language = selected;
    });

    _showMessage('Language changed to $language');
  }

  // ===============================================================
  // NOTIFICATIONS
  // ===============================================================

  Widget _notificationCard() {
    return _card(
      child: Column(
        children: [
          _switchRow(
            icon: Icons.notifications_none,
            title: 'Class Reminders',
            subtitle: 'Receive reminders before scheduled classes',
            value: classReminders,
            onChanged: (value) {
              setState(() {
                classReminders = value;
              });

              _showMessage(
                value ? 'Class reminders enabled' : 'Class reminders disabled',
              );
            },
          ),

          _divider(),

          _switchRow(
            icon: Icons.chat_bubble_outline,
            title: 'Parent Messages',
            subtitle: 'Receive messages from parents',
            value: parentMessages,
            onChanged: (value) {
              setState(() {
                parentMessages = value;
              });

              _showMessage(
                value ? 'Parent messages enabled' : 'Parent messages disabled',
              );
            },
          ),

          _divider(),

          _switchRow(
            icon: Icons.description_outlined,
            title: 'Post-Class Reports',
            subtitle: 'Receive reminders to complete class reports',
            value: postClassReports,
            onChanged: (value) {
              setState(() {
                postClassReports = value;
              });

              _showMessage(
                value
                    ? 'Post-class reports enabled'
                    : 'Post-class reports disabled',
              );
            },
          ),
        ],
      ),
    );
  }

  // ===============================================================
  // SECURITY
  // ===============================================================

  Widget _securityCard() {
    return _card(
      child: Column(
        children: [
          _switchRow(
            icon: Icons.fingerprint,
            title: 'Biometric Access',
            subtitle: 'Use Face ID or fingerprint to unlock the portal',
            value: biometricAccess,
            onChanged: _toggleBiometric,
          ),

          _divider(),

          _settingsRow(
            icon: Icons.lock_outline,
            title: 'Change Password',
            subtitle: 'Update your academy account password',
            onTap: _showChangePassword,
          ),

          _divider(),

          _settingsRow(
            icon: Icons.devices_outlined,
            title: 'Active Sessions',
            subtitle: 'Manage devices currently signed in',
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 7.w,
                  height: 7.w,
                  decoration: BoxDecoration(
                    color: AppColors.emeraldGreenColor,
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: 5.w),
                Text(
                  'iPhone 15 Pro',
                  style: TxtStyle.titleLarge(
                    color: AppColors.subtitleTextColor,
                    fontSize: 11.sp,
                  ),
                ),
                SizedBox(width: 3.w),
                Icon(
                  Icons.chevron_right,
                  color: AppColors.subtitleTextColor,
                  size: 18.sp,
                ),
              ],
            ),
            onTap: _showActiveSessions,
          ),
        ],
      ),
    );
  }

  // ===============================================================
  // BIOMETRIC
  // ===============================================================

  void _toggleBiometric(bool value) {
    setState(() {
      biometricAccess = value;
    });

    _showMessage(
      value ? 'Biometric access enabled' : 'Biometric access disabled',
    );

    // For real biometric authentication, connect this to
    // the `local_auth` package.
  }

  // ===============================================================
  // CHANGE PASSWORD
  // ===============================================================

  Future<void> _showChangePassword() async {
    final formKey = GlobalKey<FormState>();

    final currentController = TextEditingController();
    final newController = TextEditingController();
    final confirmController = TextEditingController();

    bool obscureCurrent = true;
    bool obscureNew = true;
    bool obscureConfirm = true;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.r),
              ),
              title: Text(
                'Change Password',
                style: TxtStyle.titleLarge(
                  fontSize: 17.sp,
                  fontWeight: FontWeight.w800,
                  color: AppColors.text,
                ),
              ),
              content: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _passwordField(
                        controller: currentController,
                        label: 'Current Password',
                        obscure: obscureCurrent,
                        onToggle: () {
                          setDialogState(() {
                            obscureCurrent = !obscureCurrent;
                          });
                        },
                      ),

                      SizedBox(height: 12.h),

                      _passwordField(
                        controller: newController,
                        label: 'New Password',
                        obscure: obscureNew,
                        onToggle: () {
                          setDialogState(() {
                            obscureNew = !obscureNew;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.length < 8) {
                            return 'Minimum 8 characters';
                          }
                          return null;
                        },
                      ),

                      SizedBox(height: 12.h),

                      _passwordField(
                        controller: confirmController,
                        label: 'Confirm Password',
                        obscure: obscureConfirm,
                        onToggle: () {
                          setDialogState(() {
                            obscureConfirm = !obscureConfirm;
                          });
                        },
                        validator: (value) {
                          if (value != newController.text) {
                            return 'Passwords do not match';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                  },
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (!formKey.currentState!.validate()) {
                      return;
                    }

                    Navigator.pop(dialogContext);

                    _showMessage('Password updated successfully');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryDark,
                  ),
                  child: Text(
                    'Update',
                    style: TxtStyle.titleLarge(color: Colors.white),
                  ),
                ),
              ],
            );
          },
        );
      },
    );

    currentController.dispose();
    newController.dispose();
    confirmController.dispose();
  }

  Widget _passwordField({
    required TextEditingController controller,
    required String label,
    required bool obscure,
    required VoidCallback onToggle,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      validator:
          validator ??
          (value) {
            if (value == null || value.isEmpty) {
              return '$label is required';
            }

            return null;
          },
      decoration: InputDecoration(
        labelText: label,
        suffixIcon: IconButton(
          onPressed: onToggle,
          icon: Icon(
            obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
          ),
        ),
      ),
    );
  }

  // ===============================================================
  // ACTIVE SESSIONS
  // ===============================================================

  void _showActiveSessions() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      showDragHandle: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18.r)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.fromLTRB(18.w, 5.h, 18.w, 22.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Active Sessions',
                    style: TxtStyle.titleLarge(
                      color: AppColors.text,
                      fontSize: 17.sp,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),

                SizedBox(height: 5.h),

                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'These devices currently have access to your account.',
                    style: TxtStyle.titleLarge(
                      color: AppColors.subtitleTextColor,
                      fontSize: 11.5.sp,
                    ),
                  ),
                ),

                SizedBox(height: 16.h),

                _sessionTile(
                  icon: Icons.phone_iphone,
                  device: 'iPhone 15 Pro',
                  location: 'Current device',
                  current: true,
                ),

                SizedBox(height: 8.h),

                _sessionTile(
                  icon: Icons.laptop_mac_outlined,
                  device: 'MacBook Pro',
                  location: 'Last active 2 hours ago',
                  current: false,
                ),

                SizedBox(height: 14.h),

                SizedBox(
                  width: double.infinity,
                  height: 43.h,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context);

                      _showMessage('Other sessions have been signed out');
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                      side: BorderSide(color: AppColors.error.withOpacity(.3)),
                    ),
                    child: const Text('Sign Out Other Sessions'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _sessionTile({
    required IconData icon,
    required String device,
    required String location,
    required bool current,
  }) {
    return Container(
      padding: EdgeInsets.all(11.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F7FC),
        borderRadius: BorderRadius.circular(9.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 38.w,
            height: 38.w,
            decoration: BoxDecoration(
              color: AppColors.blueSoft,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(icon, color: AppColors.primaryDark),
          ),

          SizedBox(width: 10.w),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  device,
                  style: TxtStyle.titleLarge(
                    color: AppColors.text,
                    fontSize: 12.5.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 3.h),
                Text(
                  location,
                  style: TxtStyle.titleLarge(
                    color: AppColors.subtitleTextColor,
                    fontSize: 11.sp,
                  ),
                ),
              ],
            ),
          ),

          if (current)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: const Color(0xFFE5FAEF),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Text(
                'Active',
                style: TxtStyle.titleLarge(
                  color: AppColors.emeraldGreenColor,
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ===============================================================
  // GENERIC WIDGETS
  // ===============================================================

  Widget _card({required Widget child}) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(9.r),
        border: Border.all(color: AppColors.border),
      ),
      child: child,
    );
  }

  Widget _settingsRow({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Widget? trailing,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 11.w, vertical: 12.h),
        child: Row(
          children: [
            Container(
              width: 30.w,
              height: 30.w,
              decoration: BoxDecoration(
                color: AppColors.blueSoft,
                borderRadius: BorderRadius.circular(7.r),
              ),
              child: Icon(icon, color: AppColors.primaryDark, size: 16.sp),
            ),

            SizedBox(width: 10.w),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TxtStyle.titleLarge(
                      color: AppColors.text,
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 3.h),
                  Text(
                    subtitle,
                    style: TxtStyle.bodyMedium(
                      color: AppColors.subtitleTextColor,
                      fontSize: 11.5.sp,
                      height: 1.25,
                    ),
                  ),
                ],
              ),
            ),

            if (trailing != null)
              trailing
            else
              Icon(
                Icons.chevron_right,
                color: AppColors.subtitleTextColor,
                size: 18.sp,
              ),
          ],
        ),
      ),
    );
  }

  Widget _switchRow({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 11.w, vertical: 12.h),
      child: Row(
        children: [
          Container(
            width: 30.w,
            height: 30.w,
            decoration: BoxDecoration(
              color: AppColors.blueSoft,
              borderRadius: BorderRadius.circular(7.r),
            ),
            child: Icon(icon, color: AppColors.primaryDark, size: 16.sp),
          ),

          SizedBox(width: 10.w),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TxtStyle.titleLarge(
                    color: AppColors.text,
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 3.h),
                Text(
                  subtitle,
                  style: TxtStyle.bodyMedium(
                    color: AppColors.subtitleTextColor,
                    fontSize: 11.5.sp,
                    height: 1.25,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(
            height: 30.h,
            child: Switch(
              value: value,
              onChanged: onChanged,
              activeColor: Colors.white,
              activeTrackColor: AppColors.primary,
              inactiveThumbColor: Colors.white,
              inactiveTrackColor: AppColors.inactiveBackground,
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() {
    return Container(height: 1, color: AppColors.backgroundsLinesColor);
  }

  Widget _sectionLabel(String text) {
    return Text(
      text,
      style: TxtStyle.titleLarge(
        color: AppColors.subtitleTextColor,
        fontSize: 12.5.sp,
        fontWeight: FontWeight.w800,
        letterSpacing: .5,
      ),
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TxtStyle.titleLarge(fontSize: 12.sp, color: Colors.white),
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
