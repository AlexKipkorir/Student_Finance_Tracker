import 'package:flutter/material.dart';
import 'features.dart'; // Make sure to import the FeaturesPage

class ServicesPage extends StatelessWidget {
  const ServicesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Our Services"),
      ),
      body: SingleChildScrollView(
        child: Padding( // Use Padding widget here
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Welcome to Our Finance Tracker App!",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text(
                "Here are the key services we offer to help you manage your finances efficiently:",
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),

              // Service List
              buildServiceTile(
                context,
                Icons.account_balance_wallet,
                "Expense Tracking",
                "Track your daily expenses and view reports of where your money is going.",
              ),
              buildServiceTile(
                context,
                Icons.attach_money,
                "Budget Planning",
                "Set monthly budgets for different categories and track how much you’ve spent.",
              ),
              buildServiceTile(
                context,
                Icons.pie_chart,
                "Financial Reports",
                "Get detailed financial reports and insights into your spending and saving patterns.",
              ),
              buildServiceTile(
                context,
                Icons.notifications,
                "Bill Reminders",
                "Set up reminders for upcoming bills and due payments so you never miss a deadline.",
              ),
              buildServiceTile(
                context,
                Icons.savings,
                "Savings Goals",
                "Plan and track your savings goals to stay on top of your financial objectives.",
              ),
              buildServiceTile(
                context,
                Icons.assessment,
                "Investment Tracking",
                "Monitor your investments and assets, and keep track of your portfolio performance.",
              ),
              const SizedBox(height: 20),

              // Call to Action
              Center(
                child: ElevatedButton.icon(
                  onPressed: () {
                    // Navigate to Features Page
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const FeaturesPage()),
                    );
                  },
                  icon: const Icon(Icons.explore),
                  label: const Text("Explore Features"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper function to build individual service tiles
  Widget buildServiceTile(BuildContext context, IconData icon, String title, String description) {
    return Card(
      elevation: 2,
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
      ),
    );
  }
}

