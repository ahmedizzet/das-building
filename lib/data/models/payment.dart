import 'package:isar/isar.dart';

part 'payment.g.dart';

@collection
class Payment {
  // Local auto-increment primary key (used internally by Isar)
  Id id = Isar.autoIncrement;

  // Maps to the server's _id – unique and indexed for fast lookups
  @Index(unique: true, replace: true)
  late String serverId;

  // Tenant isolation – every query should filter by this
  @Index()
  late String tenantId;

  // Resident who made the payment (maps to member.serverId)
  @Index()
  late String memberId;

  // Amount (use double for currency; if you need precision, consider Decimal)
  late double amount;

  // Type of transaction: "payment", "fee", "adjustment", etc.
  late String type;

  // Optional description / memo
  String? description;

  // Date of the transaction (when it occurred, not when recorded)
  @Index()
  late DateTime date;

  // Created at local time (set on creation)
  late DateTime createdAt;

  // Updated at local time (updated on every change)
  @Index()
  late DateTime updatedAt;

  // Soft delete timestamp (null if not deleted)
  DateTime? deletedAt;

  // Sync flags
  @Index()
  late bool isSynced;

  late bool isDeleted;
}