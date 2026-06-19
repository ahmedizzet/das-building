import 'package:flutter/material.dart';
import '../../domain/entities/expense.dart';

class DashboardProvider with ChangeNotifier {
  final List<Expense> _expenses = [
    Expense(id: '1', title: 'Elevator Repair', date: 'Oct 12', category: 'Maintenance', amount: '-1,200.00'),
    Expense(id: '2', title: 'Garden Landscaping', date: 'Oct 10', category: 'Lifestyle', amount: '-450.00'),
    Expense(id: '3', title: 'Security Staff Salary', date: 'Oct 05', category: 'Operations', amount: '-5,000.00'),
    Expense(id: '4', title: 'Water Bill', date: 'Oct 01', category: 'Utilities', amount: '-800.00'),
    Expense(id: '5', title: 'Window Cleaning', date: 'Sep 28', category: 'Maintenance', amount: '-300.00'),
    Expense(id: '6', title: 'Pool Chemical Service', date: 'Sep 15', category: 'Maintenance', amount: '-150.00'),
  ];

  String _selectedExpenseMonth = 'Oct';
  final List<String> _months = ['Aug', 'Sep', 'Oct', 'Nov'];

  List<String> get months => _months;
  String get selectedExpenseMonth => _selectedExpenseMonth;

  List<Expense> get expenses {
    return _expenses.where((e) => e.date.contains(_selectedExpenseMonth)).toList();
  }

  void setSelectedExpenseMonth(String month) {
    _selectedExpenseMonth = month;
    notifyListeners();
  }

  double get buildingBalance => 1245600.00;
  double get monthlyIncome => 85400.00;
  double get monthlyExpenses => 62100.00;

  void downloadReport() {
    // Mock download action
    print('Downloading report...');
  }
}
