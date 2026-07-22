import 'package:flutter/material.dart';

import '../../../core/database/database_helper.dart';
import '../../../shared/models/budget_model.dart';

class BudgetProvider extends ChangeNotifier {
  final List<Budget> _budgets = [];

  bool _isLoading = false;
  String? _errorMessage;

  List<Budget> get budgets => List.unmodifiable(_budgets);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadBudgets() async {
    _setLoading(true);
    _errorMessage = null;

    try {
      final budgets = await DatabaseHelper.instance.getBudgets();

      _budgets
        ..clear()
        ..addAll(budgets);
    } catch (e) {
      _errorMessage = e.toString();
    }

    _setLoading(false);
  }

  Future<void> addBudget(Budget budget) async {
    await DatabaseHelper.instance.insertBudget(budget);
    await loadBudgets();
  }

  Future<void> updateBudget(Budget budget) async {
    await DatabaseHelper.instance.updateBudget(budget);
    await loadBudgets();
  }

  Future<void> deleteBudget(Budget budget) async {
    if (budget.id == null) return;

    await DatabaseHelper.instance.deleteBudget(budget.id!);
    await loadBudgets();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
