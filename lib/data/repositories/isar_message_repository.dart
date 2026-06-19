import 'package:isar/isar.dart';
import '../../domain/entities/message.dart' as entity;
import '../../domain/repositories/message_repository.dart';
import '../models/messages.dart' as model;

class IsarMessageRepository implements MessageRepository {
  final Isar isar;

  IsarMessageRepository(this.isar);

  @override
  Future<List<entity.Message>> getMessages(String conversationId) async {
    final messages = await isar.messages
        .where()
        .conversationIdEqualTo(conversationId)
        .filter()
        .isDeletedEqualTo(false)
        .sortByCreatedAt()
        .findAll();
    return messages.map((e) => _toEntity(e)).toList();
  }

  @override
  Future<void> addMessage(entity.Message message) async {
    final now = DateTime.now();
    final newMessage = model.Message()
      ..serverId = message.id
      ..tenantId = 'default_tenant'
      ..conversationId = message.conversationId
      ..senderId = message.senderId
      ..content = message.content
      ..type = message.type
      ..readBy = []
      ..createdAt = now
      ..updatedAt = now
      ..isSynced = false
      ..isDeleted = false;

    await isar.writeTxn(() async {
      await isar.messages.put(newMessage);
    });
  }

  @override
  Stream<List<entity.Message>> watchMessages(String conversationId) {
    return isar.messages
        .where()
        .conversationIdEqualTo(conversationId)
        .filter()
        .isDeletedEqualTo(false)
        .sortByCreatedAt()
        .watch(fireImmediately: true)
        .map((messages) => messages.map((e) => _toEntity(e)).toList());
  }

  entity.Message _toEntity(model.Message m) {
    return entity.Message(
      id: m.serverId,
      conversationId: m.conversationId,
      senderId: m.senderId,
      content: m.content,
      type: m.type,
      createdAt: m.createdAt,
    );
  }
}
