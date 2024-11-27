import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dashboard.dart'; // Ensure this import matches your file structure

class FinancialReportsPage extends StatelessWidget {
  const FinancialReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Financial Reports"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Financial Reports',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              const Text(
                'Get insights into your spending and savings patterns over time. Use the reports below to analyze your financial habits.',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),
              // Financial report cards
              buildReportCard(
                context,
                Icons.bar_chart,
                "Monthly Summary",
                "View a summary of your income and expenses for the month.",
                    () => _viewMonthlySummary(context),
              ),
              buildReportCard(
                context,
                Icons.pie_chart,
                "Expense Breakdown",
                "Analyze your expenses by category to see where most of your money goes.",
                    () => _viewExpenseBreakdown(context),
              ),
              buildReportCard(
                context,
                Icons.savings,
                "Savings Progress",
                "Track your savings progress towards your financial goals.",
                    () => _viewSavingsProgress(context),
              ),
              buildReportCard(
                context,
                Icons.trending_up,
                "Income Trends",
                "See the trends in your income over time.",
                    () => _viewIncomeTrends(context),
              ),
              const SizedBox(height: 30),
              // Go Back to Dashboard Button
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const Dashboard(),
                      ),
                    ); // Navigate to the dashboard
                  },
                  child: const Text('Go Back to Dashboard'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper function to create financial report cards
  Widget buildReportCard(BuildContext context, IconData icon, String title,
      String description, VoidCallback onPress) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).primaryColor, size: 40),
        title: Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(description),
        trailing: ElevatedButton(
          onPressed: onPress,
          child: const Text('View'),
        ),
      ),
    );
  }

  // Firebase functions to retrieve and display reports
  Future<void> _viewMonthlySummary(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in first')),
      );
      return;
    }

    try {
      final userData = await FirebaseFirestore.instance
          .collection('financial_data')
          .doc(user.uid)
          .get();

      if (userData.exists) {
        final data = userData.data();
        final monthlyIncome = data?['income'] ?? 0.0;
        final monthlyExpenses = data?['expenses'] ?? 0.0;

        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Monthly Summary'),
            content: Text(
              'Income: \$${monthlyIncome.toStringAsFixed(2)}\nExpenses: \$${monthlyExpenses.toStringAsFixed(2)}',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No financial data found')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> _viewExpenseBreakdown(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in first')),
      );
      return;
    }

    try {
      final userData = await FirebaseFirestore.instance
          .collection('financial_data')
          .doc(user.uid)
          .get();

      if (userData.exists) {
        final data = userData.data();
        final expenses = data?['expenses_by_category'] ?? {};

        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Expense Breakdown'),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: expenses.entries
                    .map(
                      (entry) => Text(
                    '${entry.key}: \$${entry.value.toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 16),
                  ),
                )
                    .toList(),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No expense data found')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> _viewSavingsProgress(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in first')),
      );
      return;
    }

    try {
      final userData = await FirebaseFirestore.instance
          .collection('financial_data')
          .doc(user.uid)
          .get();

      if (userData.exists) {
        final data = userData.data();
        final savingsGoal = data?['savings_goal'] ?? 0.0;
        final savingsProgress = data?['savings_progress'] ?? 0.0;

        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Savings Progress'),
            content: Text(
              'Savings Goal: \$${savingsGoal.toStringAsFixed(2)}\nCurrent Savings: \$${savingsProgress.toStringAsFixed(2)}',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No savings data found')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> _viewIncomeTrends(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in first')),
      );
      return;
    }

    try {
      final userData = await FirebaseFirestore.instance
          .collection('financial_data')
          .doc(user.uid)
          .get();

      if (userData.exists) {
        final data = userData.data();
        final incomeHistory = List<double>.from(data?['income_history'] ?? []);

        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Income Trends'),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: incomeHistory
                    .map(
                      (income) => Text(
                    'Income: \$${income.toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 16),
                  ),
                )
                    .toList(),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No income data found')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }
}




