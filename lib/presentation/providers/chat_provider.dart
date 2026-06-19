import 'package:flutter/material.dart';
import '../../domain/entities/announcement.dart';
import '../../domain/entities/message.dart';
import '../../domain/repositories/announcement_repository.dart';
import '../../domain/repositories/message_repository.dart';

class ChatProvider with ChangeNotifier {
  final AnnouncementRepository _announcementRepository;
  final MessageRepository _messageRepository;
  List<Announcement> _allAnnouncements = [];
  List<Message> _loungeMessages = [];
  int _selectedTabIndex = 0;

  ChatProvider(this._announcementRepository, this._messageRepository) {
    _init();
  }

  void _init() {
    _announcementRepository.watchAnnouncements().listen((announcements) {
      _allAnnouncements = announcements;
      notifyListeners();
    });
    _messageRepository.watchMessages('lounge').listen((messages) {
      _loungeMessages = messages;
      notifyListeners();
    });
  }

  int get selectedTabIndex => _selectedTabIndex;

  List<Announcement> get announcements => _allAnnouncements;

  List<Announcement> get pinnedAnnouncements =>
      _allAnnouncements.where((a) => a.isPinned).toList();

  List<Announcement> get eventAnnouncements =>
      _allAnnouncements.where((a) => a.category == 'Event').toList();

  List<Message> get loungeMessages => _loungeMessages;

  void setSelectedTabIndex(int index) {
    _selectedTabIndex = index;
    notifyListeners();
  }

  Future<void> sendLoungeMessage({
    required String senderId,
    required String content,
  }) async {
    if (content.trim().isEmpty) return;
    final message = Message(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      conversationId: 'lounge',
      senderId: senderId,
      content: content.trim(),
      type: 'text',
      createdAt: DateTime.now(),
    );
    await _messageRepository.addMessage(message);
  }
}
