import 'package:flutter/material.dart';

import 'providers/budget_provider.dart';
import 'widgets/budget_card.dart';
import 'add_budget_screen.dart';
import '../../shared/models/budget_model.dart';

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

  @override
  Widget build(BuildContext context) {
    final budgets = _provider.budgets;

    return Scaffold(
      appBar: AppBar(title: const Text('Budgets'), centerTitle: true),
      body: budgets.isEmpty
          ? const Center(child: Text('No budgets yet'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: budgets.length,
              itemBuilder: (context, index) {
                final budget = budgets[index];

                return BudgetCard(
                  category: budget.category,
                  spent: budget.spent,
                  limit: budget.limit,
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final budget = await Navigator.of(context).push<Budget>(
            MaterialPageRoute(builder: (_) => const AddBudgetScreen()),
          );

          if (budget != null) {
            _provider.addBudget(budget);
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Budget'),
      ),
    );
  }
}
