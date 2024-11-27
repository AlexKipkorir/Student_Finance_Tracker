import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BudgetPlanningPage extends StatefulWidget {
  final Function(double) onBudgetSet;

  const BudgetPlanningPage({super.key, required this.onBudgetSet});

  @override
  _BudgetPlanningPageState createState() => _BudgetPlanningPageState();
}

class _BudgetPlanningPageState extends State<BudgetPlanningPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<Map<String, dynamic>> budgetCategories = [
    {"icon": Icons.home, "category": "Housing", "amount": 0.0},
    {"icon": Icons.local_grocery_store, "category": "Groceries", "amount": 0.0},
    {"icon": Icons.directions_car, "category": "Transport", "amount": 0.0},
    {"icon": Icons.local_movies, "category": "Entertainment", "amount": 0.0},
  ];

  bool _isBudgetVisible = true;
  double _plannedBudget = 0.0;
  String _userName = "User";

  @override
  void initState() {
    super.initState();
    _loadBudgetsFromFirestore();
    _loadUserData();
  }

  // Fetch only non-null custom budget categories from Firestore
  Future<void> _loadBudgetsFromFirestore() async {
    final user = _auth.currentUser;
    if (user != null) {
      final snapshot = await _firestore.collection('budgets').doc(user.uid).get();
      if (snapshot.exists) {
        final data = snapshot.data();
        setState(() {
          // Retrieve planned budget
          _plannedBudget = data?['plannedBudget'] ?? 0.0;

          // Retrieve and populate categories
          final firestoreCategories = Map<String, dynamic>.from(data?['categories'] ?? {});
          firestoreCategories.forEach((category, amount) {
            if (amount != null) {
              final existingCategory = budgetCategories.firstWhere(
                    (c) => c['category'] == category,
                orElse: () => {
                  "icon": Icons.category, // Default icon for custom categories
                  "category": category,
                  "amount": 0.0,
                },
              );
              if (!budgetCategories.contains(existingCategory)) {
                budgetCategories.add(existingCategory);
              }
              existingCategory['amount'] = amount;
            }
          });
        });
      }
    }
  }


  Future<void> _loadUserData() async {
    final user = _auth.currentUser;
    if (user != null) {
      setState(() {
        _userName = user.displayName ?? "User";
      });
    }
  }

  Future<void> _saveBudgetsToFirestore() async {
    final user = _auth.currentUser;
    if (user != null) {
      final categories = {
        for (var category in budgetCategories) category['category']: category['amount']
      };
      try {
        await _firestore.collection('budgets').doc(user.uid).set({
          'plannedBudget': _plannedBudget, // Save the planned budget
          'categories': categories, // Save the category data
          'createdAt': FieldValue.serverTimestamp(), // Auto-generate timestamp
          'userId': user.uid, // Save the user ID for reference
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Budgets saved successfully!")),
        );
        widget.onBudgetSet(_plannedBudget);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to save to Firestore")),
        );
      }
    }
  }



  double _calculateTotalBudget() {
    return budgetCategories.fold(0.0, (sum, item) => sum + item['amount']);
  }


  void _toggleBudgetVisibility() {
    setState(() {
      _isBudgetVisible = !_isBudgetVisible;
    });
  }

  void _addCustomBudgetCategory(BuildContext context) {
    final TextEditingController categoryController = TextEditingController();
    final TextEditingController initialAmountController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Custom Budget Category'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: categoryController,
                decoration: const InputDecoration(hintText: 'Category Name'),
              ),
              TextField(
                controller: initialAmountController,
                decoration: const InputDecoration(hintText: 'Initial Amount'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (categoryController.text.isNotEmpty &&
                    initialAmountController.text.isNotEmpty) {
                  setState(() {
                    budgetCategories.add({
                      "icon": Icons.category,
                      "category": categoryController.text,
                      "amount": double.parse(initialAmountController.text),
                    });
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final totalBudget = _calculateTotalBudget();
    final isOverBudget = totalBudget > _plannedBudget;

    return Scaffold(
      appBar: AppBar(title: const Text("Budget Planning")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome, $_userName',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              'This is the Budget Planning section where you can manage your expenses and set your goals to stay on track with your finances.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            const Text(
              'Budget Overview',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            const Text(
              'Planned Budget',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: TextEditingController(text: _plannedBudget.toString()),
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                hintText: 'Enter planned budget',
                border: OutlineInputBorder(),
              ),
              style: TextStyle(fontSize: 30), // Larger font for planned budget
              onChanged: (value) {
                setState(() {
                  _plannedBudget = double.tryParse(value) ?? 0.0;
                });
              },
            ),

            const SizedBox(height: 20),
            Text(
              'Total Budget: Ksh ${totalBudget.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            if (_plannedBudget > 0)
              Text(
                isOverBudget
                    ? "You have exceeded your Planned Budget!"
                    : "Your expenses are within the Planned Budget!",
                style: TextStyle(
                  fontSize: 16,
                  color: isOverBudget ? Colors.red : Colors.green,
                ),
              ),

            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _toggleBudgetVisibility,
              child: Text(_isBudgetVisible ? "Hide Budgets" : "Show Budgets"),
            ),
            const SizedBox(height: 20),
            if (_isBudgetVisible)
              ...budgetCategories.map((category) => ListTile(
                leading: Icon(category['icon']),
                title: Text(category['category']),
                subtitle: Text('Ksh ${category['amount'].toStringAsFixed(2)}'),
                onTap: () {
                  final TextEditingController amountController =
                  TextEditingController(text: category['amount'].toString());
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text('Edit Category Amount'),
                        content: TextField(
                          controller: amountController,
                          keyboardType: TextInputType.number,
                          decoration:
                          const InputDecoration(hintText: 'New Amount'),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancel'),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                category['amount'] =
                                    double.parse(amountController.text);
                              });
                              Navigator.pop(context);
                            },
                            child: const Text('Save'),
                          ),
                        ],
                      );
                    },
                  );
                },
              )),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _saveBudgetsToFirestore();
              },
              child: const Text('Save Budget'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _addCustomBudgetCategory(context);
              },
              child: const Text('Add Custom Budget Category'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Go to Dashboard'),
            ),
          ],
        ),
      ),
    );
  }
}
























