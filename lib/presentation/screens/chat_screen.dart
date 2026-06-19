import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../domain/entities/announcement.dart';
import '../../domain/entities/message.dart';
import '../providers/chat_provider.dart';
import '../providers/dashboard_provider.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage(ChatProvider chatProvider, DashboardProvider memberProvider) {
    final user = memberProvider.currentUser;
    if (user == null) return;
    final text = _messageController.text;
    if (text.trim().isEmpty) return;
    chatProvider.sendLoungeMessage(
      senderId: user.id,
      content: text,
    );
    _messageController.clear();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final chatProvider = Provider.of<ChatProvider>(context);
    final memberProvider = Provider.of<DashboardProvider>(context);

    if (chatProvider.selectedTabIndex == 1) {
      return _buildLoungeView(chatProvider, memberProvider);
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Community Chat", style: AppTypography.headlineLgMobile),
          const SizedBox(height: 16),
          SegmentedControl(
            selectedIndex: chatProvider.selectedTabIndex,
            onTabChanged: chatProvider.setSelectedTabIndex,
          ),
          const SizedBox(height: 24),
          _buildAnnouncementsTab(chatProvider),
        ],
      ),
    );
  }

  Widget _buildLoungeView(ChatProvider chatProvider, DashboardProvider memberProvider) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Community Chat", style: AppTypography.headlineLgMobile),
              const SizedBox(height: 16),
              SegmentedControl(
                selectedIndex: chatProvider.selectedTabIndex,
                onTabChanged: chatProvider.setSelectedTabIndex,
              ),
            ],
          ),
        ),
        Expanded(
          child: chatProvider.loungeMessages.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.chat_bubble_outline_rounded, size: 64, color: AppColors.outlineVariant),
                      const SizedBox(height: 16),
                      Text("No messages yet", style: AppTypography.bodyLg.copyWith(color: AppColors.onSurfaceVariant)),
                      const SizedBox(height: 8),
                      Text("Say hello to your neighbors!", style: AppTypography.bodySm.copyWith(color: AppColors.onSurfaceVariant)),
                    ],
                  ),
                )
              : ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: chatProvider.loungeMessages.length,
                  itemBuilder: (context, index) {
                    final message = chatProvider.loungeMessages[index];
                    final isMe = message.senderId == memberProvider.currentUser?.id;
                    return _MessageBubble(
                      message: message,
                      senderName: memberProvider.memberNameById(message.senderId) ?? 'Unknown',
                      isMe: isMe,
                    );
                  },
                ),
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLowest,
            border: Border(
              top: BorderSide(color: AppColors.outlineVariant.withValues(alpha: 0.5)),
            ),
          ),
          child: SafeArea(
            top: false,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: "Type a message...",
                      filled: true,
                      fillColor: AppColors.surfaceContainer,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _sendMessage(chatProvider, memberProvider),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: AppColors.primary,
                  child: IconButton(
                    icon: const Icon(Icons.send_rounded, size: 18, color: Colors.white),
                    onPressed: () => _sendMessage(chatProvider, memberProvider),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAnnouncementsTab(ChatProvider provider) {
    final pinned = provider.pinnedAnnouncements;
    final regular = provider.announcements.where((a) => !a.isPinned).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (pinned.isNotEmpty)
          ...pinned.map((a) => Padding(
            padding: const EdgeInsets.only(bottom: 24),
            child: PinnedAnnouncementCard(announcement: a),
          )),
        if (regular.isEmpty && pinned.isEmpty)
          Container(
            padding: const EdgeInsets.all(32),
            alignment: Alignment.center,
            child: Column(
              children: [
                Icon(Icons.campaign_outlined, size: 64, color: AppColors.outlineVariant),
                const SizedBox(height: 16),
                Text("No announcements yet", style: AppTypography.bodyLg.copyWith(color: AppColors.onSurfaceVariant)),
              ],
            ),
          )
        else
          ...regular.map((a) => Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: AnnouncementCard(announcement: a),
          )),
      ],
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final Message message;
  final String senderName;
  final bool isMe;

  const _MessageBubble({
    required this.message,
    required this.senderName,
    required this.isMe,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          if (!isMe)
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 2),
              child: Text(senderName, style: AppTypography.labelBold.copyWith(fontSize: 10, color: AppColors.primary)),
            ),
          Row(
            mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: [
              if (!isMe) const SizedBox(width: 0),
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: isMe ? AppColors.primary : AppColors.surfaceContainer,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: Radius.circular(isMe ? 16 : 4),
                      bottomRight: Radius.circular(isMe ? 4 : 16),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                    children: [
                      Text(
                        message.content,
                        style: AppTypography.bodyLg.copyWith(
                          color: isMe ? Colors.white : AppColors.onSurface,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        DateFormat('h:mm a').format(message.createdAt),
                        style: TextStyle(
                          fontSize: 10,
                          color: isMe ? Colors.white60 : AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (isMe) const SizedBox(width: 0),
            ],
          ),
        ],
      ),
    );
  }
}

class SegmentedControl extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTabChanged;

  const SegmentedControl({
    super.key,
    required this.selectedIndex,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => onTabChanged(0),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: selectedIndex == 0 ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: selectedIndex == 0
                      ? [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                alignment: Alignment.center,
                child: Text(
                  "Announcements",
                  style: AppTypography.labelBold.copyWith(
                    color: selectedIndex == 0 ? AppColors.primary : AppColors.onSurfaceVariant,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => onTabChanged(1),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                alignment: Alignment.center,
                child: Text(
                  "Lounge",
                  style: AppTypography.labelBold.copyWith(
                    color: selectedIndex == 1 ? AppColors.primary : AppColors.onSurfaceVariant,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class PinnedAnnouncementCard extends StatelessWidget {
  final Announcement announcement;
  const PinnedAnnouncementCard({super.key, required this.announcement});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: const Border(
          left: BorderSide(color: AppColors.primary, width: 4),
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.push_pin_rounded, size: 16, color: AppColors.primary),
              const SizedBox(width: 8),
              Text("PINNED ANNOUNCEMENT", style: AppTypography.labelBold.copyWith(color: AppColors.primary)),
            ],
          ),
          const SizedBox(height: 8),
          Text(announcement.title, style: AppTypography.headlineMd),
          const SizedBox(height: 4),
          Text(announcement.content, style: AppTypography.bodyLg),
          const SizedBox(height: 12),
          Row(
            children: [
              const CircleAvatar(radius: 12, backgroundColor: AppColors.surfaceDim, child: Icon(Icons.business, size: 14)),
              const SizedBox(width: 8),
              Text(
                "${announcement.author} • ${_formatDate(announcement.date)}",
                style: AppTypography.bodySm.copyWith(color: AppColors.onSurfaceVariant),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    if (difference.inDays > 0) return '${difference.inDays} days ago';
    if (difference.inHours > 0) return '${difference.inHours} hours ago';
    return '${difference.inMinutes} mins ago';
  }
}

class AnnouncementCard extends StatelessWidget {
  final Announcement announcement;
  const AnnouncementCard({super.key, required this.announcement});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(announcement.title, style: AppTypography.headlineMd),
          const SizedBox(height: 4),
          Text(announcement.content, style: AppTypography.bodyLg),
          const SizedBox(height: 8),
          Row(
            children: [
              const CircleAvatar(radius: 10, backgroundColor: AppColors.surfaceDim, child: Icon(Icons.person, size: 12)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  "${announcement.author} • ${DateFormat('MMM dd').format(announcement.date)}",
                  style: AppTypography.bodySm.copyWith(color: AppColors.onSurfaceVariant),
                ),
              ),
              if (announcement.category != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(announcement.category!, style: AppTypography.labelBold.copyWith(fontSize: 10)),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
