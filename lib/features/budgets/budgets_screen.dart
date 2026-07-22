import 'package:flutter/material.dart';

import '../../shared/models/budget_model.dart';
import 'add_budget_screen.dart';
import 'providers/budget_provider.dart';
import 'widgets/budget_card.dart';

class BudgetsScreen extends StatefulWidget {
  const BudgetsScreen({super.key});

  @override
  State<BudgetsScreen> createState() => _BudgetsScreenState();
}

class _BudgetsScreenState extends State<BudgetsScreen> {
  final BudgetProvider _provider = BudgetProvider();

  @override
  void initState() {
    super.initState();
    _provider.addListener(_refresh);
    _provider.loadBudgets();
  }

  @override
  void dispose() {
    _provider.removeListener(_refresh);
    _provider.dispose();
    super.dispose();
  }

  void _refresh() {
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _openAddBudgetScreen() async {
    final budget = await Navigator.of(
      context,
    ).push<Budget>(MaterialPageRoute(builder: (_) => const AddBudgetScreen()));

    if (budget == null) {
      return;
    }

    try {
      await _provider.addBudget(budget);

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Budget saved successfully')),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Unable to save budget: $error')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final budgets = _provider.budgets;
    final isLoading = _provider.isLoading;
    final errorMessage = _provider.errorMessage;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Budgets'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: _provider.loadBudgets,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null && budgets.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline, size: 48),
                    const SizedBox(height: 12),
                    Text(errorMessage, textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: _provider.loadBudgets,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Try Again'),
                    ),
                  ],
                ),
              ),
            )
          : budgets.isEmpty
          ? const Center(child: Text('No budgets yet'))
          : RefreshIndicator(
              onRefresh: _provider.loadBudgets,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: budgets.length,
                itemBuilder: (context, index) {
                  final budget = budgets[index];

                  return BudgetCard(
                    category: budget.category,
                    spent: budget.spent,
                    limit: budget.limit,
                    onDelete: () async {
                      final delete = await showDialog<bool>(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text("Delete Budget"),
                          content: Text("Delete '${budget.category}' budget?"),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text("Cancel"),
                            ),
                            FilledButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text("Delete"),
                            ),
                          ],
                        ),
                      );

                      if (delete == true) {
                        await _provider.deleteBudget(budget);
                      }
                    },
                  );
                },
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: isLoading ? null : _openAddBudgetScreen,
        icon: const Icon(Icons.add),
        label: const Text('Add Budget'),
      ),
    );
  }
}
