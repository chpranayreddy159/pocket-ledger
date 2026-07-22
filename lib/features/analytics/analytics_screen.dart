import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../core/database/database_helper.dart';
import '../../shared/models/transaction_model.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  bool _isLoading = true;
  double _income = 0;
  double _expenses = 0;
  List<TransactionModel> _transactions = [];

  @override
  void initState() {
    super.initState();
    _loadAnalytics();
  }

  Future<void> _loadAnalytics() async {
    setState(() {
      _isLoading = true;
    });

    final transactions = await DatabaseHelper.instance.getTransactions();
    final income = await DatabaseHelper.instance.getTotalIncome();
    final expenses = await DatabaseHelper.instance.getTotalExpenses();

    if (!mounted) {
      return;
    }

    setState(() {
      _transactions = transactions;
      _income = income;
      _expenses = expenses;
      _isLoading = false;
    });
  }

  Map<String, double> get _categoryTotals {
    final totals = <String, double>{};

    for (final transaction in _transactions) {
      if (transaction.type != 'expense') {
        continue;
      }

      totals.update(
        transaction.category,
        (value) => value + transaction.amount,
        ifAbsent: () => transaction.amount,
      );
    }

    final entries = totals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Map.fromEntries(entries);
  }

  double get _savings => _income - _expenses;

  double get _highestCategoryValue {
    if (_categoryTotals.isEmpty) {
      return 100;
    }

    final highest = _categoryTotals.values.reduce(
      (current, next) => current > next ? current : next,
    );

    return highest <= 0 ? 100 : highest * 1.25;
  }

  String _formatAmount(double amount) {
    if (amount >= 100000) {
      return '₹${(amount / 100000).toStringAsFixed(1)}L';
    }

    if (amount >= 1000) {
      return '₹${(amount / 1000).toStringAsFixed(1)}K';
    }

    return '₹${amount.toStringAsFixed(0)}';
  }

  List<Color> get _chartColors => const [
    Color(0xFF2563EB),
    Color(0xFF10B981),
    Color(0xFFF59E0B),
    Color(0xFF8B5CF6),
    Color(0xFFEF4444),
    Color(0xFF06B6D4),
    Color(0xFFEC4899),
    Color(0xFF64748B),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics'),
        actions: [
          IconButton(
            onPressed: _loadAnalytics,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadAnalytics,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildSummaryCards(context),
                  const SizedBox(height: 24),
                  _buildIncomeExpenseChart(context),
                  const SizedBox(height: 24),
                  _buildCategoryChart(context),
                  const SizedBox(height: 24),
                  _buildCategorySummary(context),
                ],
              ),
            ),
    );
  }

  Widget _buildSummaryCards(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _AnalyticsCard(
            label: 'Income',
            value: _formatAmount(_income),
            icon: Icons.trending_up,
            color: Colors.green,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _AnalyticsCard(
            label: 'Expenses',
            value: _formatAmount(_expenses),
            icon: Icons.trending_down,
            color: Colors.red,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _AnalyticsCard(
            label: 'Savings',
            value: _formatAmount(_savings),
            icon: Icons.savings_outlined,
            color: _savings >= 0 ? Colors.blue : Colors.red,
          ),
        ),
      ],
    );
  }

  Widget _buildIncomeExpenseChart(BuildContext context) {
    final total = _income + _expenses;

    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Income vs Expenses',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Overall cash-flow distribution',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            if (total == 0)
              const SizedBox(
                height: 220,
                child: Center(
                  child: Text('Add transactions to view analytics'),
                ),
              )
            else
              SizedBox(
                height: 230,
                child: Row(
                  children: [
                    Expanded(
                      child: PieChart(
                        PieChartData(
                          centerSpaceRadius: 55,
                          sectionsSpace: 3,
                          startDegreeOffset: -90,
                          sections: [
                            PieChartSectionData(
                              value: _income,
                              title: _income == 0
                                  ? ''
                                  : '${((_income / total) * 100).toStringAsFixed(0)}%',
                              color: Colors.green,
                              radius: 55,
                              titleStyle: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            PieChartSectionData(
                              value: _expenses,
                              title: _expenses == 0
                                  ? ''
                                  : '${((_expenses / total) * 100).toStringAsFixed(0)}%',
                              color: Colors.red,
                              radius: 55,
                              titleStyle: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _LegendItem(
                          color: Colors.green,
                          title: 'Income',
                          value: _formatAmount(_income),
                        ),
                        const SizedBox(height: 18),
                        _LegendItem(
                          color: Colors.red,
                          title: 'Expenses',
                          value: _formatAmount(_expenses),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryChart(BuildContext context) {
    final entries = _categoryTotals.entries.take(6).toList();

    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Spending by Category',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Top expense categories',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            if (entries.isEmpty)
              const SizedBox(
                height: 220,
                child: Center(child: Text('No expense data available')),
              )
            else
              SizedBox(
                height: 280,
                child: BarChart(
                  BarChartData(
                    maxY: _highestCategoryValue,
                    alignment: BarChartAlignment.spaceAround,
                    borderData: FlBorderData(show: false),
                    gridData: const FlGridData(
                      show: true,
                      drawVerticalLine: false,
                    ),
                    barTouchData: BarTouchData(
                      touchTooltipData: BarTouchTooltipData(
                        getTooltipItem: (group, groupIndex, rod, rodIndex) {
                          return BarTooltipItem(
                            '${entries[group.x].key}\n'
                            '${_formatAmount(rod.toY)}',
                            const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        },
                      ),
                    ),
                    titlesData: FlTitlesData(
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 48,
                          getTitlesWidget: (value, meta) {
                            return Text(
                              _formatAmount(value),
                              style: const TextStyle(fontSize: 10),
                            );
                          },
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 48,
                          getTitlesWidget: (value, meta) {
                            final index = value.toInt();

                            if (index < 0 || index >= entries.length) {
                              return const SizedBox.shrink();
                            }

                            final label = entries[index].key;

                            return Padding(
                              padding: const EdgeInsets.only(top: 10),
                              child: Text(
                                label.length > 7
                                    ? '${label.substring(0, 7)}…'
                                    : label,
                                style: const TextStyle(fontSize: 10),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    barGroups: List.generate(
                      entries.length,
                      (index) => BarChartGroupData(
                        x: index,
                        barRods: [
                          BarChartRodData(
                            toY: entries[index].value,
                            width: 20,
                            color: _chartColors[index % _chartColors.length],
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(6),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategorySummary(BuildContext context) {
    final entries = _categoryTotals.entries.toList();

    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Category Summary',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            if (entries.isEmpty)
              const Text('No categories to display')
            else
              ...List.generate(entries.length, (index) {
                final entry = entries[index];
                final percentage = _expenses == 0
                    ? 0.0
                    : entry.value / _expenses;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 18),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 6,
                            backgroundColor:
                                _chartColors[index % _chartColors.length],
                          ),
                          const SizedBox(width: 10),
                          Expanded(child: Text(entry.key)),
                          Text(
                            _formatAmount(entry.value),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: percentage.clamp(0, 1),
                        minHeight: 7,
                        borderRadius: BorderRadius.circular(20),
                        color: _chartColors[index % _chartColors.length],
                      ),
                    ],
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }
}

class _AnalyticsCard extends StatelessWidget {
  const _AnalyticsCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 16),
        child: Column(
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              maxLines: 1,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(label, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({
    required this.color,
    required this.title,
    required this.value,
  });

  final Color color;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title),
            Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ],
    );
  }
}
