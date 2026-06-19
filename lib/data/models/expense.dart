import 'package:isar/isar.dart';

part 'expense.g.dart';

@collection
class Expense {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String serverId;

  @Index()
  late String tenantId;

  late String title;
  late double amount;
  
  @Index()
  late DateTime date;
  late String category;

  @Index()
  late DateTime updatedAt;
  @Index()
  late bool isSynced;
  late bool isDeleted;
}
