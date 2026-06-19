import 'package:isar/isar.dart';
import '../../domain/entities/expense.dart' as entity;
import '../../domain/repositories/expense_repository.dart';
import '../models/expense.dart' as model;

class IsarExpenseRepository implements ExpenseRepository {
  final Isar isar;
  final String Function() _tenantIdProvider;

  IsarExpenseRepository(this.isar, this._tenantIdProvider);

  @override
  Future<List<entity.Expense>> getExpenses() async {
    final tenantId = _tenantIdProvider();
    final expenses = await isar.expenses
        .filter()
        .tenantIdEqualTo(tenantId)
        .and()
        .isDeletedEqualTo(false)
        .sortByDateDesc()
        .findAll();
    return expenses.map((e) => _toEntity(e)).toList();
  }

  @override
  Future<void> addExpense(entity.Expense expense, String tenantId) async {
    final newExpense = model.Expense()
      ..serverId = expense.id 
      ..tenantId = tenantId
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
    final tenantId = _tenantIdProvider();
    return isar.expenses
        .filter()
        .tenantIdEqualTo(tenantId)
        .and()
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
