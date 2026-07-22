import 'package:flutter/material.dart';

class BudgetCard extends StatelessWidget {
  final String category;
  final double spent;
  final double limit;

  const BudgetCard({
    super.key,
    required this.category,
    required this.spent,
    required this.limit,
  });

  @override
  Widget build(BuildContext context) {
    final progress = (spent / limit).clamp(0.0, 1.0);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              category,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            LinearProgressIndicator(value: progress, minHeight: 10),
            const SizedBox(height: 10),
            Text("₹${spent.toStringAsFixed(0)} / ₹${limit.toStringAsFixed(0)}"),
          ],
        ),
      ),
    );
  }
}
