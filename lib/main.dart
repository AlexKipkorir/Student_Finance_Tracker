import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:timezone/data/latest.dart' as tz; // Added to initialize timezones
import 'signup.dart';
import 'dashboard.dart';
import 'login.dart';
import 'services.dart';
import 'features.dart';
import 'expense_tracker.dart';
import 'budget_planning.dart';
import 'financial_reports.dart';
import 'bill_reminder.dart';
import 'financial_goals.dart';
import 'investment_tracking.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize timezone data
  tz.initializeTimeZones();

  if (kIsWeb) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyDQ_Xor8Azv8goQvVXNdRuggT5WMGDtqx4",
        authDomain: "student-finance-tracker-cb5e3.firebaseapp.com",
        projectId: "student-finance-tracker-cb5e3",
        storageBucket: "student-finance-tracker-cb5e3.appspot.com",
        messagingSenderId: "902151719084",
        appId: "1:902151719084:web:405aa83d8d3bd65b0ab709",
      ),
    );
  } else {
    await Firebase.initializeApp();
  }

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key}); // Removed 'const' to avoid the error

  final Map<String, double> _budgets = {};
  final Logger _logger = Logger(); // Create a Logger instance

  void _setBudget(double amount) {
    final category = "DefaultCategory"; // Placeholder or dynamically determine
    _budgets[category] = amount;

    // Save the budget to Firestore
    FirebaseFirestore.instance.collection('budgets').add({
      'category': category,
      'amount': amount,
      'timestamp': Timestamp.now(),
    }).then((value) {
      _logger.i("Budget added to Firestore"); // Use logger for info message
    }).catchError((error) {
      _logger.e("Failed to add budget: $error"); // Use logger for error message
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Finance Tracker App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginPage(),
        '/signup': (context) => const SignupPage(),
        '/dashboard': (context) => const Dashboard(),
        '/services': (context) => const ServicesPage(),
        '/features': (context) => const FeaturesPage(),
        '/expense_tracker': (context) => const ExpenseTrackerPage(),
        '/budget_planning': (context) => BudgetPlanningPage(onBudgetSet: _setBudget),
        '/financial_reports': (context) => const FinancialReportsPage(),
        '/bill_reminders': (context) => const BillRemindersPage(housingBudget: '', dueDate: '',),
        '/savings_goals': (context) => const FinancialGoalsPage(),
        '/investment_tracking': (context) => const InvestmentTrackingPage(),
      },
    );
  }
}








