import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/expense.dart';

class ExpenseService {
  static const String _expenseKey = 'expenses';
  static const String _budgetKey = 'monthly_budget';

  Future<void> addExpense(Expense expense) async {
    final prefs = await SharedPreferences.getInstance();
    final expenses = await getExpenses();
    expenses.add(expense);
    final jsonList = expenses.map((e) => e.toJson()).toList();
    await prefs.setString(_expenseKey, jsonEncode(jsonList));
  }

  Future<List<Expense>> getExpenses() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_expenseKey);
    if (json == null) return [];
    
    final List<dynamic> decoded = jsonDecode(json);
    return decoded.map((item) => Expense.fromJson(item as Map<String, dynamic>)).toList();
  }

  Future<List<Expense>> getExpensesByMonth(DateTime month) async {
    final expenses = await getExpenses();
    return expenses.where((e) => 
      e.date.year == month.year && 
      e.date.month == month.month
    ).toList();
  }

  Future<List<Expense>> getExpensesByCategory(String category) async {
    final expenses = await getExpenses();
    return expenses.where((e) => e.category == category).toList();
  }

  Future<double> getTotalExpenses() async {
    final expenses = await getExpenses();
    return expenses.fold(0, (sum, e) => sum + e.amount);
  }

  Future<Map<String, double>> getCategoryTotals() async {
    final expenses = await getExpenses();
    final Map<String, double> totals = {};
    for (var expense in expenses) {
      totals[expense.category] = (totals[expense.category] ?? 0) + expense.amount;
    }
    return totals;
  }

  Future<void> setBudget(double limit, Map<String, double> categoryLimits) async {
    final prefs = await SharedPreferences.getInstance();
    final budgetData = {
      'limit': limit,
      'categoryLimits': categoryLimits,
    };
    await prefs.setString(_budgetKey, jsonEncode(budgetData));
  }

  Future<MonthlyBudget?> getBudget() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_budgetKey);
    if (json == null) return null;
    
    final data = jsonDecode(json) as Map<String, dynamic>;
    return MonthlyBudget(
      month: DateTime.now().toString().substring(0, 7),
      limit: (data['limit'] as num).toDouble(),
      categoryLimits: Map.from(data['categoryLimits'] as Map),
    );
  }
}