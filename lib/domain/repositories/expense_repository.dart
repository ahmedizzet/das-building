import '../entities/expense.dart';

abstract class ExpenseRepository {
  Future<List<Expense>> getExpenses();
  Future<void> addExpense(Expense expense);
  Stream<List<Expense>> watchExpenses();
}
