import 'package:isar/isar.dart';

part 'messages.g.dart';

@collection
class Message {
  Id id = Isar.autoIncrement;          // local primary key

  @Index(unique: true, replace: true)
  late String serverId;                // maps to MongoDB _id

  @Index()
  late String tenantId;

  @Index()
  late String conversationId;          // optional, but index for filtering

  late String senderId;                // member.serverId
  late String content;
  late String type;                    // text, image, etc.

  @Index()
  late List<String> readBy;            // list of member IDs

  late DateTime createdAt;             // set locally on creation
  late DateTime updatedAt;

  DateTime? deletedAt;                 // nullable

  @Index()
  late bool isSynced;                  // tracks sync status
  late bool isDeleted;                 // soft delete flag
}