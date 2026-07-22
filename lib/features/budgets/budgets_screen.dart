import 'package:flutter/material.dart';
import 'widgets/budget_card.dart';

class BudgetsScreen extends StatelessWidget {
  const BudgetsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Budgets'), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          BudgetCard(category: 'Food', spent: 3500, limit: 5000),
          BudgetCard(category: 'Shopping', spent: 4200, limit: 6000),
          BudgetCard(category: 'Transport', spent: 1200, limit: 2500),
          BudgetCard(category: 'Entertainment', spent: 800, limit: 2000),
        ],
      ),
    );
  }
}
