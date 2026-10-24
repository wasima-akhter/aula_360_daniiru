import 'package:aula360/features/parent_all/data/dtos/conversation_dto.dart';
import 'package:intl/intl.dart';

import '../../../../core/network/socket_service.dart';
import '../../../share/export/screen_export.dart';
import '../controllers/chat_controller.dart';

class ChatInboxScreen extends ConsumerStatefulWidget {
  final ConversationDto? conversation;

  const ChatInboxScreen({super.key, this.conversation});

  @override
  ConsumerState<ChatInboxScreen> createState() => _ChatInboxScreenState();
}

class _ChatInboxScreenState extends ConsumerState<ChatInboxScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.conversation != null) {
        ref
            .read(chatControllerProvider.notifier)
            .selectConversation(widget.conversation!);
      } else {
        ref.read(chatControllerProvider.notifier).startAdminConversation();
      }
    });
  }

  @override
  void dispose() {
    _textController.dispose();
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
      return DateFormat('HH:mm').format(dt);
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

  void _showConnectionRequiredHint() {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.wifi_off_rounded, color: Colors.white, size: 20),
            SizedBox(width: 10.w),
            Expanded(
              child: Text(
                ref.readTr(AppStrings.chatConnectionRequiredNotice),
                style: TextStyle(fontSize: 13.sp),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.redColor,
        duration: const Duration(seconds: 4),
        showCloseIcon: true,
        closeIconColor: Colors.white,
        action: SnackBarAction(
          label: ref.readTr(AppStrings.chatReconnect),
          textColor: Colors.white,
          onPressed: () {
            ref.read(chatControllerProvider.notifier).retryConnection();
          },
        ),
      ),
    );
  }

  void _showSendFailedHint(String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white, size: 20),
            SizedBox(width: 10.w),
            Expanded(
              child: Text(message, style: TextStyle(fontSize: 13.sp)),
            ),
          ],
        ),
        backgroundColor: AppColors.redColor,
        duration: const Duration(seconds: 4),
        showCloseIcon: true,
        closeIconColor: Colors.white,
        action: SnackBarAction(
          label: ref.readTr(AppStrings.chatRetry),
          textColor: Colors.white,
          onPressed: () => _sendMessage(),
        ),
      ),
    );
  }

  Future<void> _sendMessage() async {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    final chatState = ref.read(chatControllerProvider);
    final isLive = chatState.isConnected ||
        ref.read(socketServiceProvider).isConnected;

    // If socket connection is not built, do not simulate sending and do not clear the user's draft!
    if (!isLive) {
      _showConnectionRequiredHint();
      return;
    }

    final success = await ref
        .read(chatControllerProvider.notifier)
        .sendMessage(text);
    if (success) {
      _textController.clear();
      _scrollToBottom();
    } else {
      if (mounted) {
        final errorKey =
            ref.read(chatControllerProvider).error ??
            AppStrings.chatSendFailedNotice;
        final error = ref.readTr(errorKey);
        _showSendFailedHint(error);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(chatControllerProvider);
    final isSocketLive = chatState.isConnected ||
        ref.watch(socketServiceProvider).isConnected;
    final conv = chatState.selectedConversation ?? widget.conversation;

    ref.listen(chatControllerProvider.select((s) => s.messages.length), (
      previous,
      next,
    ) {
      if (next > (previous ?? 0)) {
        _scrollToBottom();
      }
    });

    final title = conv?.participantName?.isNotEmpty == true
        ? conv!.participantName!
        : (conv?.participant?.fullName.isNotEmpty == true
              ? conv!.participant!.fullName
              : ref.watchTr(AppStrings.adminName));

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) {
          ref
              .read(chatControllerProvider.notifier)
              .leaveCurrentConversation();
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F7FC),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: false,
          leading: IconButton(
            onPressed: () {
              ref
                  .read(chatControllerProvider.notifier)
                  .leaveCurrentConversation();
              context.pop();
            },
            icon: Icon(
              Icons.arrow_back,
              color: AppColors.primaryDark,
              size: 21.sp,
            ),
          ),
          title: Row(
            children: [
              Stack(
                children: [
                  Container(
                    width: 38.w,
                    height: 38.w,
                    decoration: const BoxDecoration(
                      color: AppColors.blueSoft,
                      shape: BoxShape.circle,
                    ),
                    child: ClipOval(
                      child: conv?.displayAvatar?.isNotEmpty == true
                          ? Image.network(
                              conv!.displayAvatar!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) => _adminAvatar(),
                            )
                          : _adminAvatar(),
                    ),
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 10.w,
                      height: 10.w,
                      decoration: BoxDecoration(
                        color: isSocketLive
                            ? AppColors.emeraldGreenColor
                            : Colors.grey,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1.5),
                      ),
                    ),
                  ),
                ],
              ),
            SizedBox(width: 10.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TxtStyle.titleLarge(
                      color: AppColors.primaryDark,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    chatState.isOtherTyping
                        ? ref.watchTr(AppStrings.typingIndicator)
                        : (isSocketLive
                              ? ref.watchTr(AppStrings.chatOnlineChannel)
                              : ref.watchTr(AppStrings.chatReconnecting)),
                    style: TextStyle(
                      color: chatState.isOtherTyping
                          ? AppColors.primary
                          : (isSocketLive
                                ? AppColors.emeraldGreenColor
                                : Colors.grey),
                      fontSize: 12.sp,
                      fontWeight: chatState.isOtherTyping
                          ? FontWeight.w700
                          : FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          if (!isSocketLive)
            Padding(
              padding: EdgeInsets.only(right: 8.w),
              child: IconButton(
                tooltip: ref.watchTr(AppStrings.chatReconnectTooltip),
                onPressed: () {
                  ref.read(chatControllerProvider.notifier).retryConnection();
                },
                icon: Icon(
                  Icons.sync_problem_rounded,
                  color: AppColors.redColor,
                  size: 22.sp,
                ),
              ),
            ),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1.h),
          child: Container(height: 1, color: AppColors.backgroundsLinesColor),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            if (!isSocketLive)
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                color: const Color(0xFFFFF3CD),
                child: Row(
                  children: [
                    Icon(
                      Icons.wifi_off_rounded,
                      size: 18.sp,
                      color: const Color(0xFF856404),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            ref.watchTr(AppStrings.chatOfflineTitle),
                            style: TextStyle(
                              color: const Color(0xFF856404),
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            ref.watchTr(AppStrings.chatOfflineDesc),
                            style: TextStyle(
                              color: const Color(0xFF856404),
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 8.w),
                    InkWell(
                      onTap: () {
                        ref
                            .read(chatControllerProvider.notifier)
                            .retryConnection();
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10.w,
                          vertical: 6.h,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF856404),
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        child: Text(
                          ref.watchTr(AppStrings.chatReconnect),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11.5.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            Expanded(
              child: chatState.isLoading && chatState.messages.isEmpty
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    )
                  : chatState.messages.isEmpty
                  ? _emptyChatView(ref)
                  : ListView.builder(
                      controller: _scrollController,
                      physics: const AlwaysScrollableScrollPhysics(
                        parent: BouncingScrollPhysics(),
                      ),
                      padding: EdgeInsets.fromLTRB(14.w, 14.h, 14.w, 14.h),
                      itemCount:
                          chatState.messages.length +
                          (chatState.isOtherTyping ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == chatState.messages.length &&
                            chatState.isOtherTyping) {
                          return _typingBubble(ref);
                        }
                        final msg = chatState.messages[index];
                        final isMe = _isMe(msg, conv);

                        return Padding(
                          padding: EdgeInsets.only(bottom: 10.h),
                          child: isMe
                              ? _outgoingBubble(msg)
                              : _incomingBubble(msg, title),
                        );
                      },
                    ),
            ),
            _messageComposer(chatState, isSocketLive),
          ],
        ),
      ),
    ),
    );
  }

  Widget _adminAvatar() {
    return Container(
      color: AppColors.blueSoft,
      alignment: Alignment.center,
      child: Icon(Icons.account_balance, color: AppColors.primary, size: 20.sp),
    );
  }

  Widget _emptyChatView(WidgetRef ref) {
    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 30.h),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 64.w,
              height: 64.w,
              decoration: BoxDecoration(
                color: AppColors.softSlateBgColor,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.mark_chat_unread_outlined,
                size: 32.sp,
                color: AppColors.subtitleTextColor,
              ),
            ),
            SizedBox(height: 14.h),
            Text(
              ref.watchTr(AppStrings.noMessagesYet),
              textAlign: TextAlign.center,
              style: TxtStyle.titleLarge(
                color: AppColors.text,
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              ref.watchTr(AppStrings.noMessagesYetDesc),
              textAlign: TextAlign.center,
              style: TxtStyle.bodyMedium(
                color: AppColors.secondaryText,
                fontSize: 13.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _outgoingBubble(ChatMessageDto msg) {
    return Align(
      alignment: Alignment.centerRight,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.78,
        ),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(14.r),
              topRight: Radius.circular(14.r),
              bottomLeft: Radius.circular(14.r),
              bottomRight: Radius.circular(3.r),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                msg.body,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14.sp,
                  height: 1.35,
                ),
              ),
              SizedBox(height: 4.h),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _formatTime(msg.sentAt),
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.75),
                      fontSize: 11.sp,
                    ),
                  ),
                  SizedBox(width: 4.w),
                  Icon(
                    Icons.done_all_rounded,
                    size: 13.sp,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _incomingBubble(ChatMessageDto msg, String senderName) {
    return Align(
      alignment: Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.78,
        ),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(14.r),
              topRight: Radius.circular(14.r),
              bottomRight: Radius.circular(14.r),
              bottomLeft: Radius.circular(3.r),
            ),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                senderName,
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 11.5.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 3.h),
              Text(
                msg.body,
                style: TextStyle(
                  color: AppColors.text,
                  fontSize: 14.sp,
                  height: 1.35,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                _formatTime(msg.sentAt),
                style: TextStyle(
                  color: AppColors.subtitleTextColor,
                  fontSize: 11.sp,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _typingBubble(WidgetRef ref) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(bottom: 8.h),
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 12.w,
              height: 12.w,
              child: const CircularProgressIndicator(
                strokeWidth: 1.5,
                color: AppColors.primary,
              ),
            ),
            SizedBox(width: 8.w),
            Text(
              ref.watchTr(AppStrings.typingIndicator),
              style: TextStyle(
                color: AppColors.secondaryText,
                fontSize: 12.sp,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _messageComposer(ChatState state, bool isLive) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (!isLive)
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 5.h),
            color: const Color(0xFFFEE2E2),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  color: const Color(0xFF991B1B),
                  size: 14.sp,
                ),
                SizedBox(width: 6.w),
                Expanded(
                  child: Text(
                    ref.watchTr(AppStrings.chatOfflineStrip),
                    style: TextStyle(
                      color: const Color(0xFF991B1B),
                      fontSize: 11.5.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                InkWell(
                  onTap: () {
                    ref.read(chatControllerProvider.notifier).retryConnection();
                  },
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 4.w,
                      vertical: 2.h,
                    ),
                    child: Text(
                      ref.watchTr(AppStrings.chatRetry),
                      style: TextStyle(
                        color: const Color(0xFF991B1B),
                        fontSize: 11.5.sp,
                        fontWeight: FontWeight.w800,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(
              top: BorderSide(color: AppColors.backgroundsLinesColor),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _textController,
                  onChanged: (val) {
                    ref.read(chatControllerProvider.notifier).onUserTyping(val);
                  },
                  onSubmitted: (_) => _sendMessage(),
                  maxLines: null,
                  style: TextStyle(fontSize: 14.sp, color: AppColors.text),
                  decoration: InputDecoration(
                    hintText: isLive
                        ? ref.watchTr(AppStrings.typeMessageHint)
                        : ref.watchTr(AppStrings.chatTypeMessageOfflineHint),
                    hintStyle: TextStyle(
                      color: AppColors.subtitleTextColor,
                      fontSize: 13.5.sp,
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(
                      vertical: 10.h,
                      horizontal: 6.w,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              GestureDetector(
                onTap: state.isSending ? null : _sendMessage,
                child: Container(
                  width: 42.w,
                  height: 42.w,
                  decoration: BoxDecoration(
                    color: isLive
                        ? AppColors.primary
                        : Colors.grey.shade400,
                    shape: BoxShape.circle,
                  ),
                  child: state.isSending
                      ? const Center(
                          child: SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          ),
                        )
                      : Icon(
                          isLive
                              ? Icons.send_rounded
                              : Icons.send_outlined,
                          color: Colors.white,
                          size: 19.sp,
                        ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
