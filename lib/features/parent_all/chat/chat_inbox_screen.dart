import '../../share/export/screen_export.dart';
import '../data/dtos/conversation_dto.dart';
import '../presentation/controllers/parent_chat_controller.dart';
import '../presentation/controllers/parent_children_controller.dart';

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
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  String _formatTime(String? iso) {
    if (iso == null || iso.isEmpty) return '12:00';
    try {
      final dt = DateTime.parse(iso).toLocal();
      return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return '12:00';
    }
  }

  bool _isMe(ChatMessageDto msg, ConversationDto? conv) {
    if (msg.senderId == 'me') return true;
    final otherId = conv?.participant?.id;
    if (otherId != null && otherId.isNotEmpty && msg.senderId == otherId) {
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(parentChatControllerProvider);
    final chatController = ref.read(parentChatControllerProvider.notifier);
    final activeChild =
        ref.watch(parentChildrenControllerProvider).selectedChild;

    final conv = chatState.selectedConversation;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F7FC),
      appBar: _chatAppBar(chatState, conv, activeChild),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: RefreshIndicator(
                color: AppColors.primary,
                onRefresh: () => chatController.loadConversations(),
                child: SingleChildScrollView(
                  controller: _scrollController,
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  padding: EdgeInsets.fromLTRB(14.w, 10.h, 14.w, 20.h),
                  child: Column(
                    children: [
                      _chatTabs(chatState, chatController),
                      SizedBox(height: 15.h),
                      _dateDivider(),
                      SizedBox(height: 12.h),

                      if (chatState.isLoading && chatState.messages.isEmpty)
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 40.h),
                          child: const Center(
                            child: CircularProgressIndicator(
                              color: AppColors.primary,
                            ),
                          ),
                        )
                      else if (chatState.messages.isEmpty)
                        _emptyChatPlaceholder()
                      else ...[
                        for (final msg in chatState.messages) ...[
                          if (_isMe(msg, conv)) ...[
                            _outgoingMessage(
                              msg.body,
                              _formatTime(msg.sentAt),
                            ),
                            SizedBox(height: 12.h),
                          ] else ...[
                            _messageLabel(
                              msg.sender?.fullName ?? conv?.displayName ?? 'Profesor',
                            ),
                            SizedBox(height: 6.h),
                            _incomingMessage(
                              msg.body,
                              _formatTime(msg.sentAt),
                            ),
                            SizedBox(height: 12.h),
                          ],
                        ],
                      ],
                    ],
                  ),
                ),
              ),
            ),
            _messageComposer(chatState, chatController),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _chatAppBar(
    ParentChatState state,
    ConversationDto? conv,
    dynamic activeChild,
  ) {
    final title = conv?.displayName ?? 'Dña. Sarah Vance';
    final childInfo = activeChild != null
        ? '${activeChild.name} • ${activeChild.grade}'
        : 'Lucas Rivera • ${ref.watchTr(AppStrings.eso2)}';

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
              Flexible(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TxtStyle.titleLarge(
                    color: AppColors.primaryDark,
                    fontSize: 17.sp,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              SizedBox(width: 5.w),
              Container(
                width: 7.w,
                height: 7.w,
                decoration: BoxDecoration(
                  color: state.isConnected
                      ? AppColors.emeraldGreenColor
                      : Colors.grey,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Text(
            childInfo,
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

  Widget _chatTabs(
    ParentChatState state,
    ParentChatController controller,
  ) {
    final isTutoring = state.selectedTab == 0;

    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F3F7),
        borderRadius: BorderRadius.circular(18.r),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => controller.selectTab(0),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                alignment: Alignment.center,
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: isTutoring ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(15.r),
                  boxShadow: isTutoring
                      ? [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: .05),
                            blurRadius: 3,
                          ),
                        ]
                      : null,
                ),
                child: Text(
                  ref.watchTr(AppStrings.chatTutoringTab),
                  style: TxtStyle.titleLarge(
                    color: isTutoring
                        ? AppColors.primaryDark
                        : AppColors.subtitleTextColor,
                    fontSize: 14.sp,
                    fontWeight: isTutoring ? FontWeight.w700 : FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => controller.selectTab(1),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                alignment: Alignment.center,
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: !isTutoring ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(15.r),
                  boxShadow: !isTutoring
                      ? [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: .05),
                            blurRadius: 3,
                          ),
                        ]
                      : null,
                ),
                child: Text(
                  ref.watchTr(AppStrings.chatAdministrationTab),
                  style: TxtStyle.titleLarge(
                    color: !isTutoring
                        ? AppColors.primaryDark
                        : AppColors.subtitleTextColor,
                    fontSize: 14.sp,
                    fontWeight: !isTutoring ? FontWeight.w700 : FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyChatPlaceholder() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 40.h, horizontal: 20.w),
      child: Column(
        children: [
          Container(
            width: 50.w,
            height: 50.w,
            decoration: const BoxDecoration(
              color: AppColors.blueSoft,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.chat_bubble_outline,
              size: 24.sp,
              color: AppColors.primaryDark,
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            'Sin mensajes previos',
            style: TxtStyle.titleLarge(
              color: AppColors.text,
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            'Escribe un mensaje para comunicarte directamente.',
            textAlign: TextAlign.center,
            style: TxtStyle.titleLarge(
              color: AppColors.subtitleTextColor,
              fontSize: 13.5.sp,
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
            'CHAT EN TIEMPO REAL',
            style: TxtStyle.titleLarge(
              color: AppColors.subtitleTextColor,
              fontSize: 12.sp,
              fontWeight: FontWeight.w700,
              letterSpacing: .5,
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
          fontSize: 13.5.sp,
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
            fontSize: 12.sp,
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
                fontSize: 12.sp,
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

  Widget _messageComposer(
    ParentChatState state,
    ParentChatController controller,
  ) {
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
                onSubmitted: (_) async {
                  final text = _messageController.text;
                  _messageController.clear();
                  final success = await controller.sendMessage(text);
                  if (success) _scrollToBottom();
                },
              ),
            ),
          ),
          SizedBox(width: 7.w),
          GestureDetector(
            onTap: state.isSending
                ? null
                : () async {
                    final text = _messageController.text;
                    if (text.trim().isEmpty) return;
                    _messageController.clear();
                    final success = await controller.sendMessage(text);
                    if (success) _scrollToBottom();
                  },
            child: Container(
              width: 31.w,
              height: 31.w,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: AppColors.primaryDark,
                shape: BoxShape.circle,
              ),
              child: state.isSending
                  ? SizedBox(
                      width: 14.w,
                      height: 14.w,
                      child: const CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Icon(Icons.send, color: Colors.white, size: 14.sp),
            ),
          ),
        ],
      ),
    );
  }
}
