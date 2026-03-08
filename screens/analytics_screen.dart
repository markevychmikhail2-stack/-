import 'package:flutter/material.dart';
import '../services/expense_service.dart';
import '../models/expense.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({Key? key}) : super(key: key);

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  final ExpenseService _expenseService = ExpenseService();
  late Future<List<Expense>> _expensesFuture;

  @override
  void initState() {
    super.initState();
    _expensesFuture = _expenseService.getExpenses();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Аналітика')),
      body: FutureBuilder<List<Expense>>(
        future: _expensesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('Немає даних для аналізу'),
            );
          }

          final expenses = snapshot.data!;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStatistics(expenses),
                const SizedBox(height: 24),
                _buildMonthlyTrend(expenses),
                const SizedBox(height: 24),
                _buildCategoryChart(expenses),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatistics(List<Expense> expenses) {
    final total = expenses.fold<double>(0, (sum, e) => sum + e.amount);
    final average = total / (expenses.isEmpty ? 1 : expenses.length);

    return Column(
      children: [
        Card(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.shade400, Colors.blue.shade700],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatCard('Всього', '${total.toStringAsFixed(2)} ₴', Colors.white),
                _buildStatCard('Середньо', '${average.toStringAsFixed(2)} ₴', Colors.white),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return Column(
      children: [
        Text(label, style: TextStyle(color: color, fontSize: 12)),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildMonthlyTrend(List<Expense> expenses) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Тренд по місяцях', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text('Графік буде додано з бібліотекою fl_chart'),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryChart(List<Expense> expenses) {
    final categories = <String, double>{};
    for (var expense in expenses) {
      categories[expense.category] = (categories[expense.category] ?? 0) + expense.amount;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Розподіл по категоріям', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        ...categories.entries.map((entry) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(entry.key, style: const TextStyle(fontWeight: FontWeight.w500)),
                    Text('${entry.value.toStringAsFixed(2)} ₴', style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ],
    );
  }
}