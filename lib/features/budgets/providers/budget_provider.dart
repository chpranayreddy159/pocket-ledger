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
    } catch (error) {
      _errorMessage = 'Unable to load budgets: $error';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> addBudget(Budget budget) async {
    _errorMessage = null;

    try {
      await DatabaseHelper.instance.insertBudget(budget);
      await loadBudgets();
    } catch (error) {
      _errorMessage = 'Unable to save budget: $error';
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateBudget(Budget budget) async {
    _errorMessage = null;

    try {
      await DatabaseHelper.instance.updateBudget(budget);
      await loadBudgets();
    } catch (error) {
      _errorMessage = 'Unable to update budget: $error';
      notifyListeners();
      rethrow;
    }
  }

  Future<void> deleteBudget(int id) async {
    _errorMessage = null;

    try {
      await DatabaseHelper.instance.deleteBudget(id);
      await loadBudgets();
    } catch (error) {
      _errorMessage = 'Unable to delete budget: $error';
      notifyListeners();
      rethrow;
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
