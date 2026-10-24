import 'package:aula360/features/parent_all/data/dtos/conversation_dto.dart';
import 'package:intl/intl.dart';

import '../../../share/export/screen_export.dart';
import '../controllers/chat_controller.dart';

class ChatListScreen extends ConsumerWidget {
  const ChatListScreen({super.key});

  String _formatDate(String? isoDate, WidgetRef ref) {
    if (isoDate == null || isoDate.isEmpty) return '';
    try {
      final dt = DateTime.parse(isoDate).toLocal();
      final now = DateTime.now();
      if (dt.year == now.year && dt.month == now.month && dt.day == now.day) {
        return DateFormat('HH:mm').format(dt);
      }
      final yesterday = now.subtract(const Duration(days: 1));
      if (dt.year == yesterday.year &&
          dt.month == yesterday.month &&
          dt.day == yesterday.day) {
        return ref.watchTr(AppStrings.yesterday);
      }
      return DateFormat('d MMM').format(dt);
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chatState = ref.watch(chatControllerProvider);
    final chatController = ref.read(chatControllerProvider.notifier);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F7FC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.primaryDark, size: 21.sp),
          onPressed: () => context.pop(),
        ),
        title: Text(
          ref.watchTr(AppStrings.chatListTitle),
          style: TxtStyle.titleLarge(
            color: AppColors.primaryDark,
            fontSize: 18.sp,
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 14.w),
            child: InkWell(
              borderRadius: BorderRadius.circular(12.r),
              onTap: chatState.isConnected
                  ? null
                  : () => chatController.retryConnection(),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: chatState.isConnected
                      ? AppColors.emeraldGreenColor.withValues(alpha: 0.12)
                      : Colors.grey.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6.w,
                      height: 6.w,
                      decoration: BoxDecoration(
                        color: chatState.isConnected
                            ? AppColors.emeraldGreenColor
                            : Colors.grey,
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 5.w),
                    Text(
                      chatState.isConnected
                          ? ref.watchTr(AppStrings.liveBadge)
                          : ref.watchTr(AppStrings.offlineBadge),
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w700,
                        color: chatState.isConnected
                            ? AppColors.emeraldGreenColor
                            : Colors.grey,
                      ),
                    ),
                  ],
                ),
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
        child: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () => chatController.loadConversations(),
          child: chatState.isLoading && chatState.conversations.isEmpty
              ? const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                )
              : chatState.conversations.isEmpty
              ? _emptyConversationsPlaceholder(context, ref, chatController)
              : ListView.separated(
                  padding: EdgeInsets.symmetric(
                    horizontal: 14.w,
                    vertical: 14.h,
                  ),
                  itemCount: chatState.conversations.length,
                  separatorBuilder: (_, _) => SizedBox(height: 10.h),
                  itemBuilder: (context, index) {
                    final conv = chatState.conversations[index];
                    return _conversationTile(
                      context,
                      ref,
                      conv,
                      chatController,
                    );
                  },
                ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final conv = await chatController.startAdminConversation();
          if (context.mounted) {
            final activeConv =
                conv ?? ref.read(chatControllerProvider).selectedConversation;
            if (activeConv != null) {
              context.push(RoutePath.chatInbox, extra: activeConv);
            } else {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    ref.readTr(AppStrings.chatTargetAdminNotFound),
                  ),
                  backgroundColor: AppColors.primaryDark,
                  duration: const Duration(seconds: 4),
                ),
              );
            }
          }
        },
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.chat_bubble_outline, color: Colors.white),
        label: Text(
          ref.watchTr(AppStrings.chatWithAdmin),
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 13.5.sp,
          ),
        ),
      ),
    );
  }

  Widget _conversationTile(
    BuildContext context,
    WidgetRef ref,
    ConversationDto conv,
    ChatController controller,
  ) {
    final title = conv.participantName?.isNotEmpty == true
        ? conv.participantName!
        : (conv.participant?.fullName.isNotEmpty == true
              ? conv.participant!.fullName
              : ref.watchTr(AppStrings.adminName));

    final lastMessage = conv.lastMessage?.isNotEmpty == true
        ? conv.lastMessage!
        : ref.watchTr(AppStrings.noMessagesYet);

    final time = _formatDate(conv.lastMessageAt ?? conv.updatedAt, ref);

    return InkWell(
      onTap: () {
        controller.selectConversation(conv);
        context.push(RoutePath.chatInbox, extra: conv);
      },
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Stack(
              children: [
                Container(
                  width: 48.w,
                  height: 48.w,
                  decoration: const BoxDecoration(
                    color: AppColors.blueSoft,
                    shape: BoxShape.circle,
                  ),
                  child: ClipOval(
                    child: conv.displayAvatar?.isNotEmpty == true
                        ? Image.network(
                            conv.displayAvatar!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => _adminAvatarFallback(),
                          )
                        : _adminAvatarFallback(),
                  ),
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 16.w,
                    height: 16.w,
                    decoration: BoxDecoration(
                      color: const Color(0xFF07348A),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: Icon(Icons.shield, color: Colors.white, size: 9.sp),
                  ),
                ),
              ],
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TxtStyle.titleLarge(
                            color: AppColors.text,
                            fontSize: 15.5.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      if (time.isNotEmpty) ...[
                        SizedBox(width: 6.w),
                        Text(
                          time,
                          style: TextStyle(
                            color: AppColors.subtitleTextColor,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ],
                  ),
                  SizedBox(height: 4.h),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          lastMessage,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TxtStyle.bodyMedium(
                            color: conv.unreadCount > 0
                                ? AppColors.text
                                : AppColors.secondaryText,
                            fontSize: 13.sp,
                          ),
                        ),
                      ),
                      if (conv.unreadCount > 0) ...[
                        SizedBox(width: 6.w),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 7.w,
                            vertical: 2.h,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          child: Text(
                            '${conv.unreadCount}',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _adminAvatarFallback() {
    return Container(
      color: AppColors.blueSoft,
      alignment: Alignment.center,
      child: Icon(Icons.account_balance, color: AppColors.primary, size: 24.sp),
    );
  }

  Widget _emptyConversationsPlaceholder(
    BuildContext context,
    WidgetRef ref,
    ChatController controller,
  ) {
    return Center(
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 40.h),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72.w,
              height: 72.w,
              decoration: BoxDecoration(
                color: AppColors.softSlateBgColor,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.chat_bubble_outline_rounded,
                size: 36.sp,
                color: AppColors.subtitleTextColor,
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              ref.watchTr(AppStrings.noConversationsTitle),
              textAlign: TextAlign.center,
              style: TxtStyle.titleLarge(
                color: AppColors.text,
                fontSize: 17.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              ref.watchTr(AppStrings.noConversationsDesc),
              textAlign: TextAlign.center,
              style: TxtStyle.bodyMedium(
                color: AppColors.secondaryText,
                fontSize: 13.5.sp,
              ),
            ),
            SizedBox(height: 20.h),
            ElevatedButton.icon(
              onPressed: () async {
                final conv = await controller.startAdminConversation();
                if (context.mounted) {
                  final activeConv = conv ??
                      ref.read(chatControllerProvider).selectedConversation;
                  if (activeConv != null) {
                    context.push(RoutePath.chatInbox, extra: activeConv);
                  } else {
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          ref.readTr(AppStrings.chatTargetAdminNotFound),
                        ),
                        backgroundColor: AppColors.primaryDark,
                        duration: const Duration(seconds: 4),
                      ),
                    );
                  }
                }
              },
              icon: const Icon(Icons.send_outlined, size: 16),
              label: Text(ref.watchTr(AppStrings.chatWithAdmin)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
