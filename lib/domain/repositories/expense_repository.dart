import '../entities/expense.dart';

abstract class ExpenseRepository {
  Future<List<Expense>> getExpenses();
  Future<void> addExpense(Expense expense, String tenantId);
  Stream<List<Expense>> watchExpenses();
}
