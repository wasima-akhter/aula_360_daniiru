import '../../share/export/screen_export.dart';

class TeacherInformationScreen extends StatelessWidget {
  const TeacherInformationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F7FC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F7FC),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: Icon(
            Icons.arrow_back,
            color: const Color(0xFF062B78),
            size: 21.sp,
          ),
        ),
        title: Text(
          'Teacher Information',
          style: TxtStyle.titleLarge(
            color: const Color(0xFF082E78),
            fontSize: 21.sp,
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          Icon(Icons.more_vert, color: const Color(0xFF082E78), size: 22.sp),
          SizedBox(width: 10.w),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 30.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _studentHeader(),
            SizedBox(height: 14.h),
            _teacherProfile(),
            SizedBox(height: 16.h),
            _communicationCard(),
          ],
        ),
      ),
    );
  }

  Widget _studentHeader() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 2.w),
      child: Row(
        children: [
          Text(
            'Lucas Rivera',
            style: TxtStyle.titleLarge(
              color: const Color(0xFF123579),
              fontSize: 15.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
          _dot(),
          Text(
            'Grade 8, Room 3B',
            style: TxtStyle.titleLarge(
              color: const Color(0xFF667085),
              fontSize: 14.5.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          Container(
            width: 6.w,
            height: 6.w,
            decoration: const BoxDecoration(
              color: Color(0xFF24B47E),
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 5.w),
          Text(
            'Active Term',
            style: TxtStyle.titleLarge(
              color: const Color(0xFF20A779),
              fontSize: 14.5.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _dot() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8.w),
      child: Container(
        width: 3.w,
        height: 3.w,
        decoration: const BoxDecoration(
          color: Color(0xFF9BA3B2),
          shape: BoxShape.circle,
        ),
      ),
    );
  }

  Widget _teacherProfile() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(17.w, 17.h, 17.w, 17.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xFFE3E6EF)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .025),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _teacherAvatar(),
              SizedBox(width: 13.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Mr. Robert Hayes',
                      style: TxtStyle.titleLarge(
                        color: const Color(0xFF20283B),
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 3.h),
                    Text(
                      'Head of Mathematics & STEM Faculty',
                      style: TxtStyle.titleLarge(
                        color: const Color(0xFF082E78),
                        fontSize: 15.5.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      'St. Matthew Preparatory School •\n#FAC-4092',
                      style: TxtStyle.titleLarge(
                        color: const Color(0xFF687083),
                        fontSize: 14.5.sp,
                        height: 1.35,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: 14.h),

          Divider(height: 1, color: const Color(0xFFE2E5EB)),

          SizedBox(height: 12.h),

          Text(
            'M.Ed. in Secondary Mathematics with 12 years\n'
            'instructional leadership in calculus, algebra\n'
            'foundations, and STEM development.',
            style: TxtStyle.titleLarge(
              color: const Color(0xFF626B7B),
              fontSize: 15.5.sp,
              height: 1.55,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _teacherAvatar() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 60.w,
          height: 60.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFFE7EBF2),
            border: Border.all(color: const Color(0xFFE2E6ED), width: 1),
          ),
          child: ClipOval(
            child: Image.asset(
              'assets/images/teacher.png',
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) {
                return Icon(
                  Icons.person,
                  size: 36.sp,
                  color: const Color(0xFF8791A3),
                );
              },
            ),
          ),
        ),
        Positioned(
          right: -2.w,
          bottom: 0,
          child: Container(
            width: 18.w,
            height: 18.w,
            decoration: BoxDecoration(
              color: const Color(0xFF07348A),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: Icon(Icons.verified, color: Colors.white, size: 11.sp),
          ),
        ),
      ],
    );
  }

  Widget _communicationCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(17.w, 18.h, 17.w, 18.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xFFE2E5ED)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.forum_outlined,
                color: const Color(0xFF082E78),
                size: 20.sp,
              ),
              SizedBox(width: 7.w),
              Text(
                'Direct Communication',
                style: TxtStyle.titleLarge(
                  color: const Color(0xFF20283B),
                  fontSize: 19.sp,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),

          SizedBox(height: 14.h),

          _messageBox(),

          SizedBox(height: 12.h),

          _officeHours(),

          SizedBox(height: 12.h),

          _emailBox(),
        ],
      ),
    );
  }

  Widget _messageBox() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(12.w, 11.h, 12.w, 12.h),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F3F8),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Portal Direct Message',
            style: TxtStyle.titleLarge(
              color: const Color(0xFF263149),
              fontSize: 15.5.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 9.h),
          _primaryButton(
            icon: Icons.send_outlined,
            text: 'Send Message',
            onTap: () {
              AppRouter.navigatorKey.currentContext!.push(RoutePath.chatInbox);
            },
          ),
        ],
      ),
    );
  }

  Widget _officeHours() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(12.w, 11.h, 12.w, 12.h),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F3F8),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Office Hours & Consultation',
            style: TxtStyle.titleLarge(
              color: const Color(0xFF263149),
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            'Wed & Thu • 3:30 – 4:30 PM (Room 3B / Virtual)',
            style: TxtStyle.titleLarge(
              color: const Color(0xFF6B7485),
              fontSize: 14.8.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 9.h),
          SizedBox(
            width: double.infinity,

            child: ElevatedButton.icon(
              onPressed: () {},
              icon: Icon(
                Icons.calendar_month_outlined,
                size: 14.sp,
                color: const Color(0xFF082E78),
              ),
              label: Text(
                'Request Meeting',
                style: TxtStyle.titleLarge(
                  color: const Color(0xFF082E78),
                  fontSize: 15.5.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: const Color(0xFFDCE5FF),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(7.r),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _emailBox() {
    return Container(
      width: double.infinity,
      height: 38.h,
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(7.r),
        border: Border.all(color: const Color(0xFFDDE2EB)),
      ),
      child: Row(
        children: [
          Icon(Icons.mail_outline, color: const Color(0xFF667085), size: 17.sp),
          SizedBox(width: 9.w),
          Text(
            'r.hayes@stmatthewprep.edu',
            style: TxtStyle.titleLarge(
              color: const Color(0xFF123A82),
              fontSize: 14.8.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _primaryButton({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 31.h,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, color: Colors.white, size: 13.sp),
        label: Text(
          text,
          style: TxtStyle.titleLarge(
            color: Colors.white,
            fontSize: 15.5.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: const Color(0xFF052E82),
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(7.r),
          ),
        ),
      ),
    );
  }
}
