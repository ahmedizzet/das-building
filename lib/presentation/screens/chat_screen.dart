import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../domain/entities/announcement.dart';
import '../../domain/entities/message.dart';
import '../providers/chat_provider.dart';
import '../providers/dashboard_provider.dart';
import '../widgets/modern_components.dart';

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
          const SectionHeader(title: "Community Chat"),
          const SizedBox(height: 8),
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
              const SectionHeader(title: "Community Chat"),
              const SizedBox(height: 8),
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
          child: SafeArea(
            top: false,
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.3)),
                    ),
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: "Type a message...",
                        filled: true,
                        fillColor: Colors.transparent,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _sendMessage(chatProvider, memberProvider),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primary, AppColors.primaryContainer],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        blurRadius: 8,
                      ),
                    ],
                  ),
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
          GlassCard(
            padding: const EdgeInsets.all(32),
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
              padding: const EdgeInsets.only(left: 4, bottom: 4),
              child: Text(senderName, style: AppTypography.labelBold.copyWith(fontSize: 10, color: AppColors.primary)),
            ),
          Row(
            mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: [
              if (!isMe) const SizedBox(width: 0),
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    gradient: isMe
                        ? LinearGradient(
                            colors: [AppColors.primary, AppColors.primaryContainer],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : null,
                    color: isMe ? null : Colors.white.withValues(alpha: 0.85),
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(18),
                      topRight: const Radius.circular(18),
                      bottomLeft: Radius.circular(isMe ? 18 : 4),
                      bottomRight: Radius.circular(isMe ? 4 : 18),
                    ),
                    border: isMe ? null : Border.all(color: Colors.white.withValues(alpha: 0.5)),
                    boxShadow: [
                      BoxShadow(
                        color: (isMe ? AppColors.primary : Colors.black).withValues(alpha: 0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
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
                      const SizedBox(height: 4),
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
        color: Colors.white.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => onTabChanged(0),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  gradient: selectedIndex == 0
                      ? LinearGradient(
                          colors: [
                            AppColors.primary.withValues(alpha: 0.9),
                            AppColors.primary,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : null,
                  color: selectedIndex == 0 ? null : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: selectedIndex == 0
                      ? [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.2),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                alignment: Alignment.center,
                child: Text(
                  "Announcements",
                  style: AppTypography.labelBold.copyWith(
                    color: selectedIndex == 0 ? Colors.white : AppColors.onSurfaceVariant,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => onTabChanged(1),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  gradient: selectedIndex == 1
                      ? LinearGradient(
                          colors: [
                            AppColors.primary.withValues(alpha: 0.9),
                            AppColors.primary,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : null,
                  color: selectedIndex == 1 ? null : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: selectedIndex == 1
                      ? [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.2),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                alignment: Alignment.center,
                child: Text(
                  "Lounge",
                  style: AppTypography.labelBold.copyWith(
                    color: selectedIndex == 1 ? Colors.white : AppColors.onSurfaceVariant,
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
    return GlassCard(
      accentColor: AppColors.primary,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.push_pin_rounded, size: 14, color: AppColors.primary),
              ),
              const SizedBox(width: 8),
              Text("PINNED ANNOUNCEMENT", style: AppTypography.labelBold.copyWith(color: AppColors.primary)),
            ],
          ),
          const SizedBox(height: 12),
          Text(announcement.title, style: AppTypography.headlineMd),
          const SizedBox(height: 4),
          Text(announcement.content, style: AppTypography.bodyLg),
          const SizedBox(height: 12),
          Row(
            children: [
              CircleAvatar(
                radius: 12,
                backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                child: const Icon(Icons.business, size: 14, color: AppColors.primary),
              ),
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
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(announcement.title, style: AppTypography.headlineMd),
          const SizedBox(height: 4),
          Text(announcement.content, style: AppTypography.bodyLg),
          const SizedBox(height: 12),
          Row(
            children: [
              CircleAvatar(
                radius: 10,
                backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                child: const Icon(Icons.person, size: 12, color: AppColors.primary),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  "${announcement.author} • ${DateFormat('MMM dd').format(announcement.date)}",
                  style: AppTypography.bodySm.copyWith(color: AppColors.onSurfaceVariant),
                ),
              ),
              if (announcement.category != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.secondary.withValues(alpha: 0.2)),
                  ),
                  child: Text(announcement.category!, style: AppTypography.labelBold.copyWith(fontSize: 10, color: AppColors.secondary)),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
