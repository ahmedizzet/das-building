import 'package:isar/isar.dart';
import '../../domain/entities/expense.dart' as entity;
import '../../domain/repositories/expense_repository.dart';
import '../models/expense.dart' as model;

class IsarExpenseRepository implements ExpenseRepository {
  final Isar isar;

  IsarExpenseRepository(this.isar);

  @override
  Future<List<entity.Expense>> getExpenses() async {
    final expenses = await isar.expenses.where().filter().isDeletedEqualTo(false).sortByDateDesc().findAll();
    return expenses.map((e) => _toEntity(e)).toList();
  }

  @override
  Future<void> addExpense(entity.Expense expense) async {
    final newExpense = model.Expense()
      ..serverId = expense.id // In a real app, this might be temporary or generated
      ..tenantId = 'default_tenant' // This would come from an auth service
      ..title = expense.title
      ..amount = expense.amount
      ..date = expense.date
      ..category = expense.category
      ..updatedAt = DateTime.now()
      ..isSynced = false
      ..isDeleted = false;

    await isar.writeTxn(() async {
      await isar.expenses.put(newExpense);
    });
  }

  @override
  Stream<List<entity.Expense>> watchExpenses() {
    return isar.expenses
        .where()
        .filter()
        .isDeletedEqualTo(false)
        .sortByDateDesc()
        .watch(fireImmediately: true)
        .map((expenses) => expenses.map((e) => _toEntity(e)).toList());
  }

  entity.Expense _toEntity(model.Expense m) {
    return entity.Expense(
      id: m.serverId,
      title: m.title,
      date: m.date,
      category: m.category,
      amount: m.amount,
    );
  }
}
