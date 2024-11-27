import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'budget_planning.dart';
import 'services.dart';
import 'about_us.dart';
import 'expense_tracker.dart';
import 'financial_reports.dart';
import 'financial_goals.dart';
import 'bill_reminder.dart';
import 'investment_tracking.dart';
import 'login.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  double _totalBalance = 0.0;
  double _monthlyIncome = 0.0;
  double _monthlyExpenses = 0.0;
  final Map<String, double> _budgets = {};
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String _userName = "User";

  @override
  void initState() {
    super.initState();
    _fetchUserData();
    _fetchUserBudgets();
  }

  Future<void> _fetchUserData() async {
    final user = _auth.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (doc.exists) {
        setState(() {
          _userName = doc['name'] ?? "User";
          _totalBalance = doc['totalBalance'] ?? 0.0;
          _monthlyIncome = doc['monthlyIncome'] ?? 0.0;
          _monthlyExpenses = doc['monthlyExpenses'] ?? 0.0;
        });
      } else {
        showSignUpPopup();
      }
    }
  }

  Future<void> _fetchUserBudgets() async {
    final user = _auth.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance.collection('budgets').doc(user.uid).get();
      if (doc.exists) {
        final data = doc.data();
        setState(() {
          _budgets.clear();
          if (data != null && data['categories'] != null) {
            final categories = Map<String, dynamic>.from(data['categories']);
            categories.forEach((category, amount) {
              _budgets[category] = amount;
            });
          }
        });
      }
    }
  }

  // Updated Function to update the budget
  void _updateBudget(double amount) {
    const category = "DefaultCategory"; // Placeholder or dynamically determine
    setState(() {
      _budgets[category] = amount;
    });

    // Optionally, update the budget in Firestore as well
    final user = _auth.currentUser;
    if (user != null) {
      FirebaseFirestore.instance.collection('budgets').doc(user.uid).set({
        'categories': _budgets,
      });
    }
  }

  Future<void> showSignUpPopup() async {
    final user = _auth.currentUser;
    if (user != null) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Please complete your sign-up'),
            content: const Text('You need to complete your sign-up details.'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                  );
                },
                child: const Text('Sign Up'),
              ),
            ],
          );
        },
      );
    }
  }

  Future<void> _showFinancialOverviewPopup() async {
    final user = _auth.currentUser;
    if (user != null) {
      double? balance = _totalBalance;
      double? income = _monthlyIncome;
      double? expenses = _monthlyExpenses;

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Edit Financial Overview'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  decoration: const InputDecoration(labelText: 'Total Balance'),
                  keyboardType: TextInputType.number,
                  controller: TextEditingController(text: balance.toString()),
                  onChanged: (value) {
                    balance = double.tryParse(value);
                  },
                ),
                TextField(
                  decoration: const InputDecoration(labelText: 'Monthly Income'),
                  keyboardType: TextInputType.number,
                  controller: TextEditingController(text: income.toString()),
                  onChanged: (value) {
                    income = double.tryParse(value);
                  },
                ),
                TextField(
                  decoration: const InputDecoration(labelText: 'Monthly Expenses'),
                  keyboardType: TextInputType.number,
                  controller: TextEditingController(text: expenses.toString()),
                  onChanged: (value) {
                    expenses = double.tryParse(value);
                  },
                ),
              ],
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (balance != null && income != null && expenses != null) {
                    await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
                      'totalBalance': balance,
                      'monthlyIncome': income,
                      'monthlyExpenses': expenses,
                    });

                    setState(() {
                      _totalBalance = balance!;
                      _monthlyIncome = income!;
                      _monthlyExpenses = expenses!;
                    });

                    Navigator.of(context).pop();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please enter valid amounts.')),
                    );
                  }
                },
                child: const Text('Save'),
              ),
            ],
          );
        },
      );
    }
  }

  // Helper function to create an interactive card
  Widget _buildInteractiveCard(BuildContext context, IconData icon, String title, String subtitle, Widget page) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).primaryColor),
        title: Text(title),
        subtitle: Text(subtitle),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => page),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Dashboard"),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _showFinancialOverviewPopup,
            tooltip: 'Edit Financial Overview',
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                'Navigation Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            _buildDrawerItem(context, Icons.info, 'About Us', const AboutUsPage()),
            _buildDrawerItem(context, Icons.build, 'Services', const ServicesPage()),
            _buildDrawerItem(context, Icons.monetization_on, 'Expense Tracker', const ExpenseTrackerPage()),
            _buildDrawerItem(context, Icons.account_balance_wallet, 'Budget Planning', BudgetPlanningPage(onBudgetSet: _updateBudget)),
            _buildDrawerItem(context, Icons.assessment, 'Financial Reports', const FinancialReportsPage()),
            _buildDrawerItem(context, Icons.savings, 'Financial Goals', const FinancialGoalsPage()),
            _buildDrawerItem(context, Icons.notifications, 'Bill Reminders', const BillRemindersPage(housingBudget: '', dueDate: '',)),
            _buildDrawerItem(context, Icons.trending_up, 'Investment Tracking', const InvestmentTrackingPage()),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () => _showLogoutConfirmationDialog(),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome, $_userName!',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            const Text(
              'Your financial overview at a glance:',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            const Text(
              'Financial Overview:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            _buildDashboardCard(context, Icons.attach_money, "Total Balance", "Ksh$_totalBalance"),
            _buildDashboardCard(context, Icons.trending_up, "Monthly Income", "Ksh$_monthlyIncome"),
            _buildDashboardCard(context, Icons.trending_down, "Monthly Expenses", "Ksh$_monthlyExpenses"),
            const SizedBox(height: 20),
            const Text(
              'Budget Section:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            _buildInteractiveCard(
              context,
              Icons.category,
              "Tap to view your budget",
              "Tap to view your budgets and set new ones",
              BudgetPlanningPage(onBudgetSet: _updateBudget),
            ),
            const SizedBox(height: 20),
            const Text(
              'Upcoming Bill Reminders:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            _buildInteractiveCard(context, Icons.notifications, "Upcoming Bill Reminders", "Tap to view your reminders", const BillRemindersPage(housingBudget: '', dueDate: '',)),
            const SizedBox(height: 20),
            const Text(
              'Financial Goals:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            _buildInteractiveCard(context, Icons.savings, "Set Your Financial Goals", "Tap to manage your goals", const FinancialGoalsPage()),
            const SizedBox(height: 20),
            const Text(
              'Investment Tracking:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            _buildInteractiveCard(context, Icons.trending_up, "Manage Your Investments", "Tap to track your investments", const InvestmentTrackingPage()),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardCard(BuildContext context, IconData icon, String title, String value) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).primaryColor),
        title: Text(title),
        subtitle: Text(value),
      ),
    );
  }

  Widget _buildDrawerItem(BuildContext context, IconData icon, String title, Widget page) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => page),
        );
      },
    );
  }

  Future<void> _showLogoutConfirmationDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                await _auth.signOut();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                );
              },
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }
}

































