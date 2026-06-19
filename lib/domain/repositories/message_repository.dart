import '../entities/message.dart';

abstract class MessageRepository {
  Future<List<Message>> getMessages(String conversationId);
  Future<void> addMessage(Message message);
  Stream<List<Message>> watchMessages(String conversationId);
}
