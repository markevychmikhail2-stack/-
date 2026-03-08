class Expense {
  final String id;
  final String category;
  final double amount;
  final String description;
  final DateTime date;
  final String currency;

  Expense({
    required this.id,
    required this.category,
    required this.amount,
    required this.description,
    required this.date,
    this.currency = 'UAH',
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'category': category,
    'amount': amount,
    'description': description,
    'date': date.toIso8601String(),
    'currency': currency,
  };

  factory Expense.fromJson(Map<String, dynamic> json) => Expense(
    id: json['id'] as String,
    category: json['category'] as String,
    amount: (json['amount'] as num).toDouble(),
    description: json['description'] as String,
    date: DateTime.parse(json['date'] as String),
    currency: json['currency'] as String? ?? 'UAH',
  );
}

class MonthlyBudget {
  final String month;
  final double limit;
  final Map<String, double> categoryLimits;

  MonthlyBudget({
    required this.month,
    required this.limit,
    required this.categoryLimits,
  });
}