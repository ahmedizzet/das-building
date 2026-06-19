import '../../domain/entities/expense.dart';
import '../../domain/repositories/expense_repository.dart';

class MockExpenseRepository implements ExpenseRepository {
  final List<Expense> _mockExpenses = [
    Expense(id: '1', title: 'Elevator Repair (Mock)', date: DateTime(2023, 10, 12), category: 'Maintenance', amount: -1200.00),
    Expense(id: '2', title: 'Garden (Mock)', date: DateTime(2023, 10, 10), category: 'Lifestyle', amount: -450.00),
  ];

  @override
  Future<List<Expense>> getExpenses() async => _mockExpenses;

  @override
  Future<void> addExpense(Expense expense) async {
    _mockExpenses.add(expense);
  }

  @override
  Stream<List<Expense>> watchExpenses() async* {
    yield _mockExpenses;
  }
}
