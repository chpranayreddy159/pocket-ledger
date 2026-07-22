import 'package:flutter/material.dart';

class Budget {
  final String category;
  final double spent;
  final double limit;

  Budget({required this.category, required this.spent, required this.limit});
}

class BudgetProvider extends ChangeNotifier {
  final List<Budget> _budgets = [
    Budget(category: 'Food', spent: 3500, limit: 5000),
    Budget(category: 'Shopping', spent: 4200, limit: 6000),
    Budget(category: 'Transport', spent: 1200, limit: 2500),
    Budget(category: 'Entertainment', spent: 800, limit: 2000),
  ];

  List<Budget> get budgets => _budgets;

  void addBudget(Budget budget) {
    _budgets.add(budget);
    notifyListeners();
  }
}
