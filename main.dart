import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/add_expense_screen.dart';
import 'screens/analytics_screen.dart';
import 'screens/ai_advisor_screen.dart';

void main() {
  runApp(const FinanceApp());
}

class FinanceApp extends StatelessWidget {
  const FinanceApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Розумний Трекер Витрат',
      theme: ThemeData(
        primarySwatch: Colors.green,
        useMaterial3: true,
        brightness: Brightness.light,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF2E7D32),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Color(0xFF2E7D32),
        ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.green,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1B5E20),
          foregroundColor: Colors.white,
        ),
      ),
      home: const HomeScreen(),
      routes: {
        '/add_expense': (context) => const AddExpenseScreen(),
        '/analytics': (context) => const AnalyticsScreen(),
        '/ai_advisor': (context) => const AiAdvisorScreen(),
      },
    );
  }
}