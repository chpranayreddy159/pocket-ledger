import 'package:flutter/material.dart';

class BudgetCard extends StatelessWidget {
  final String category;
  final double spent;
  final double limit;
  final VoidCallback? onDelete;

  const BudgetCard({
    super.key,
    required this.category,
    required this.spent,
    required this.limit,
    this.onDelete,
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  category,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: onDelete,
                ),
              ],
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
