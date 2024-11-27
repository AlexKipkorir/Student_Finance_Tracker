import 'package:flutter/material.dart';

class FeaturesPage extends StatelessWidget {
  const FeaturesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Features"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              "Explore Our Features",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            // Feature buttons
            buildFeatureButton(context, "Expense Tracking", Icons.account_balance_wallet, () {
              Navigator.pushNamed(context, '/expense_tracker'); // Ensure you set up this route
            }),
            buildFeatureButton(context, "Budget Planning", Icons.attach_money, () {
              Navigator.pushNamed(context, '/budget_planning'); // Ensure you set up this route
            }),
            buildFeatureButton(context, "Financial Reports", Icons.pie_chart, () {
              Navigator.pushNamed(context, '/financial_reports'); // Ensure you set up this route
            }),
            buildFeatureButton(context, "Bill Reminders", Icons.notifications, () {
              Navigator.pushNamed(context, '/bill_reminders'); // Ensure you set up this route
            }),
            buildFeatureButton(context, "Savings Goals", Icons.savings, () {
              Navigator.pushNamed(context, '/savings_goals'); // Ensure you set up this route
            }),
            buildFeatureButton(context, "Investment Tracking", Icons.assessment, () {
              Navigator.pushNamed(context, '/investment_tracking'); // Ensure you set up this route
            }),
          ],
        ),
      ),
    );
  }

  Widget buildFeatureButton(BuildContext context, String title, IconData icon, VoidCallback onPressed) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 20),
          backgroundColor: Colors.blueAccent, // Change color as needed
          textStyle: const TextStyle(fontSize: 18),
        ),
        onPressed: onPressed,
        icon: Icon(icon, size: 30),
        label: Text(title),
      ),
    );
  }
}
