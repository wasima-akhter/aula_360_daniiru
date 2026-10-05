import '../../share/export/screen_export.dart';

/// ===============================================================
/// 1. TEACHER CHAT SCREEN / CHAT CON PROFESOR
/// ===============================================================

class TeacherChatScreen extends ConsumerStatefulWidget {
  const TeacherChatScreen({super.key});

  @override
  ConsumerState<TeacherChatScreen> createState() => _TeacherChatScreenState();
}

class _TeacherChatScreenState extends ConsumerState<TeacherChatScreen> {
  final TextEditingController _messageController = TextEditingController();

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F7FC),
      appBar: _chatAppBar(),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.fromLTRB(14.w, 10.h, 14.w, 20.h),
                child: Column(
                  children: [
                    _chatTabs(),
                    SizedBox(height: 15.h),
                    _dateDivider(),
                    SizedBox(height: 12.h),

                    _messageLabel('Dña. Vance • Tutora y Matemáticas'),
                    SizedBox(height: 6.h),

                    _incomingMessage(
                      'Buenas tardes Sres. Rivera.\n\n'
                          'Lucas completó su evaluación de matemáticas '
                          'de forma excelente (94%). '
                          'Por favor asegúrense de que revise los ejercicios '
                          'del Tema 6 este fin de semana.',
                      '11:42',
                    ),

                    SizedBox(height: 12.h),

                    _outgoingMessage(
                      '¡Muchas gracias Dña. Vance! Hemos visto la '
                          'tarea actualizada y repasaremos el Tema 6 '
                          'juntos esta tarde.',
                      '12:05',
                    ),

                    SizedBox(height: 12.h),

                    _messageLabel('Dña. Vance'),
                    SizedBox(height: 6.h),

                    _incomingMessage(
                      '¡Perfecto! Avísenme si necesita cualquier '
                          'aclaración adicional durante la tutoría '
                          'del lunes.',
                      '12:18',
                    ),
                  ],
                ),
              ),
            ),
            _messageComposer(),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _chatAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        onPressed: () => context.pop(),
        icon: Icon(Icons.arrow_back, color: AppColors.primaryDark, size: 21.sp),
      ),
      title: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Dña. Sarah Vance',
                style: TxtStyle.titleLarge(
                  color: AppColors.primaryDark,
                  fontSize: 17.sp,
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(width: 5.w),
              Container(
                width: 6.w,
                height: 6.w,
                decoration: const BoxDecoration(
                  color: AppColors.emeraldGreenColor,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Text(
            'Lucas Rivera • ${ref.watchTr(AppStrings.eso2)}',
            style: TxtStyle.titleLarge(
              color: AppColors.subtitleTextColor,
              fontSize: 13.5.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
      bottom: PreferredSize(
        preferredSize: Size.fromHeight(1.h),
        child: Container(height: 1, color: AppColors.backgroundsLinesColor),
      ),
    );
  }

  Widget _chatTabs() {
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F3F7),
        borderRadius: BorderRadius.circular(18.r),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              alignment: Alignment.center,
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: .05),
                    blurRadius: 3,
                  ),
                ],
              ),
              child: Text(
                ref.watchTr(AppStrings.chatTutoringTab),
                style: TxtStyle.titleLarge(
                  color: AppColors.primaryDark,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                ref.watchTr(AppStrings.chatAdministrationTab),
                style: TxtStyle.titleLarge(
                  color: AppColors.subtitleTextColor,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _dateDivider() {
    return Row(
      children: [
        Expanded(
          child: Container(height: 1, color: AppColors.backgroundsLinesColor),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 10.w),
          child: Text(
            'HOY, 24 OCT',
            style: TxtStyle.titleLarge(
              color: AppColors.subtitleTextColor,
              fontSize: 13.5.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Expanded(
          child: Container(height: 1, color: AppColors.backgroundsLinesColor),
        ),
      ],
    );
  }

  Widget _messageLabel(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: TxtStyle.titleLarge(
          color: AppColors.blueTextColor,
          fontSize: 15.sp,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _incomingMessage(String message, String time) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          constraints: BoxConstraints(maxWidth: 285.w),
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 11.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(10.r),
              topRight: Radius.circular(10.r),
              bottomRight: Radius.circular(10.r),
              bottomLeft: Radius.circular(3.r),
            ),
            border: Border.all(color: AppColors.border),
          ),
          child: Text(
            message,
            style: TxtStyle.titleLarge(
              color: AppColors.text,
              fontSize: 14.5.sp,
              height: 1.5,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          time,
          style: TxtStyle.titleLarge(
            color: AppColors.subtitleTextColor,
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _outgoingMessage(String message, String time) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Container(
          constraints: BoxConstraints(maxWidth: 285.w),
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 11.h),
          decoration: BoxDecoration(
            color: AppColors.primaryDark,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(10.r),
              topRight: Radius.circular(3.r),
              bottomLeft: Radius.circular(10.r),
              bottomRight: Radius.circular(10.r),
            ),
          ),
          child: Text(
            message,
            style: TxtStyle.titleLarge(
              color: Colors.white,
              fontSize: 14.5.sp,
              height: 1.5,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        SizedBox(height: 4.h),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              time,
              style: TxtStyle.titleLarge(
                color: AppColors.subtitleTextColor,
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(width: 3.w),
            Icon(Icons.done_all, size: 12.sp, color: AppColors.primary),
          ],
        ),
      ],
    );
  }

  Widget _messageComposer() {
    return Container(
      padding: EdgeInsets.fromLTRB(12.w, 8.h, 12.w, 10.h),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.backgroundsLinesColor)),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () {},
            padding: EdgeInsets.zero,
            constraints: BoxConstraints(minWidth: 32.w, minHeight: 40.h),
            icon: Icon(
              Icons.attach_file,
              color: AppColors.subtitleTextColor,
              size: 19.sp,
            ),
          ),
          Expanded(
            child: SizedBox(
              height: 39.h,
              child: TextField(
                controller: _messageController,
                style: TxtStyle.titleLarge(
                  color: AppColors.text,
                  fontSize: 14.sp,
                ),
                decoration: InputDecoration(
                  hintText: ref.watchTr(AppStrings.typeMessageHint),
                  hintStyle: TextStyle(
                    color: AppColors.hintTextColor,
                    fontSize: 14.sp,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.only(bottom: 9.h),
                ),
              ),
            ),
          ),
          SizedBox(width: 7.w),
          GestureDetector(
            onTap: () {},
            child: Container(
              width: 31.w,
              height: 31.w,
              decoration: const BoxDecoration(
                color: AppColors.primaryDark,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.send, color: Colors.white, size: 14.sp),
            ),
          ),
        ],
      ),
    );
  }
}
