import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/expense.dart';

class AiService {
  static const String _baseUrl = 'http://localhost:5000/api';
  
  Future<String> getFinancialAdvice(List<Expense> expenses) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/advice'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'expenses': expenses.map((e) => e.toJson()).toList(),
        }),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['advice'] ?? 'Не вдалося отримати поради';
      } else {
        return 'Помилка отримання порад: ${response.statusCode}';
      }
    } catch (e) {
      return 'Помилка підключення: $e';
    }
  }

  Future<Map<String, dynamic>> getBudgetForecast(List<Expense> expenses) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/budget-forecast'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'expenses': expenses.map((e) => e.toJson()).toList(),
        }),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Помилка прогнозування');
      }
    } catch (e) {
      throw Exception('Помилка: $e');
    }
  }
}