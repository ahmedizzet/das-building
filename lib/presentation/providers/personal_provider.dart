import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../domain/entities/expense.dart';
import '../../domain/entities/payment.dart';
import '../../domain/repositories/expense_repository.dart';
import '../../domain/repositories/payment_repository.dart';
import 'dashboard_provider.dart';
import '../../core/utils/id_generator.dart';

class PersonalProvider with ChangeNotifier {
  final ExpenseRepository _expenseRepository;
  final PaymentRepository _paymentRepository;
  List<Expense> _allExpenses = [];
  List<Payment> _allPayments = [];
  late List<String> _months;
  String _selectedExpenseMonth;
  String _selectedPaymentMonth;

  PersonalProvider(this._expenseRepository, this._paymentRepository)
      : _selectedExpenseMonth = DateFormat('MMM').format(DateTime.now()),
        _selectedPaymentMonth = DateFormat('MMM').format(DateTime.now()) {
    _months = _generateMonths();
    _init();
  }

  List<String> _generateMonths() {
    final now = DateTime.now();
    final months = <String>[];
    for (int i = 3; i >= 0; i--) {
      final date = DateTime(now.year, now.month - i, 1);
      months.add(DateFormat('MMM').format(date));
    }
    return months;
  }

  void _init() {
    _expenseRepository.watchExpenses().listen((expenses) {
      _allExpenses = expenses;
      notifyListeners();
    });
    _paymentRepository.watchPayments().listen((payments) {
      _allPayments = payments;
      notifyListeners();
    });
  }

  List<String> get months => _months;
  String get selectedExpenseMonth => _selectedExpenseMonth;
  String get selectedPaymentMonth => _selectedPaymentMonth;

  int _monthIndex(String abbr) {
    final months = {
      'Jan': 1, 'Feb': 2, 'Mar': 3, 'Apr': 4, 'May': 5, 'Jun': 6,
      'Jul': 7, 'Aug': 8, 'Sep': 9, 'Oct': 10, 'Nov': 11, 'Dec': 12,
    };
    return months[abbr] ?? DateTime.now().month;
  }

  List<Expense> get expenses {
    final targetMonth = _monthIndex(_selectedExpenseMonth);
    return _allExpenses.where((e) => e.date.month == targetMonth).toList();
  }

  List<Payment> get payments {
    final targetMonth = _monthIndex(_selectedPaymentMonth);
    return _allPayments.where((p) => p.date.month == targetMonth).toList();
  }

  void setSelectedExpenseMonth(String month) {
    _selectedExpenseMonth = month;
    notifyListeners();
  }

  void setSelectedPaymentMonth(String month) {
    _selectedPaymentMonth = month;
    notifyListeners();
  }

  Future<void> addExpense({
    required String title,
    required double amount,
    required String category,
    required DateTime date,
    String tenantId = 'default_tenant',
  }) async {
    final newExpense = Expense(
      id: IdGenerator.generate(),
      title: title,
      amount: amount,
      category: category,
      date: date,
    );
    await _expenseRepository.addExpense(newExpense, tenantId);
  }

  Future<void> makePayment({
    required double amount,
    required String memberId,
    String? description,
  }) async {
    final newPayment = Payment(
      id: IdGenerator.generate(),
      memberId: memberId,
      amount: amount,
      type: 'payment',
      description: description,
      date: DateTime.now(),
    );
    await _paymentRepository.addPayment(newPayment);
  }

  double _buildingBalance = 1245600.00;

  double get buildingBalance => _buildingBalance;

  void setBuildingBalance(double value) {
    _buildingBalance = value;
    notifyListeners();
  }

  double get monthlyIncome {
    final now = DateTime.now();
    return _allPayments
        .where((p) => p.date.month == now.month && p.date.year == now.year)
        .fold(0.0, (sum, p) => sum + p.amount.abs());
  }

  double get monthlyExpenses {
    return expenses.where((e) => e.amount < 0).fold(0, (sum, e) => sum + e.amount.abs());
  }

  void downloadReport() {
    print('Downloading report...');
  }
}
