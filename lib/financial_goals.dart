import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'dashboard.dart'; // Ensure this import matches your file structure

class FinancialGoalsPage extends StatefulWidget {
  const FinancialGoalsPage({super.key});

  @override
  State<FinancialGoalsPage> createState() => _FinancialGoalsPageState();
}

class _FinancialGoalsPageState extends State<FinancialGoalsPage> {
  final List<Map<String, dynamic>> _savingsGoals = [];

  @override
  void initState() {
    super.initState();
    _fetchGoals();
  }

  // Fetch goals from Firestore
  void _fetchGoals() async {
    final snapshot = await FirebaseFirestore.instance.collection('goals').get();
    setState(() {
      _savingsGoals.clear();
      for (var doc in snapshot.docs) {
        _savingsGoals.add({
          'name': doc['name'],
          'amount': doc['amount'],
        });
      }
    });
  }

  // Add goal to Firestore
  void _addGoalToFirestore(String name, double amount) async {
    await FirebaseFirestore.instance.collection('goals').add({
      'name': name,
      'amount': amount,
    });
    _fetchGoals(); // Refresh the list after adding the goal
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Savings Goals"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Navigate back to the previous screen
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Track Your Savings Goals',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              const Text(
                'Plan and monitor your savings goals to achieve your financial objectives.',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _showAddGoalDialog,
                child: const Text('Add Savings Goal'),
              ),
              const SizedBox(height: 20),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _savingsGoals.length,
                itemBuilder: (context, index) {
                  final goal = _savingsGoals[index];
                  return Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ListTile(
                      title: Text(
                        goal['name'],
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text('Target: Ksh${goal['amount']}'),
                    ),
                  );
                },
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

  void _showAddGoalDialog() {
    final TextEditingController goalNameController = TextEditingController();
    final TextEditingController goalAmountController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add Savings Goal'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: goalNameController,
                decoration: const InputDecoration(hintText: 'Goal Name'),
              ),
              TextField(
                controller: goalAmountController,
                decoration: const InputDecoration(hintText: 'Target Amount'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (goalNameController.text.isNotEmpty &&
                    goalAmountController.text.isNotEmpty) {
                  _addGoalToFirestore(
                    goalNameController.text,
                    double.tryParse(goalAmountController.text) ?? 0.0,
                  );
                  Navigator.of(context).pop(); // Close the dialog
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }
}

