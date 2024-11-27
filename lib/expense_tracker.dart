import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dashboard.dart';

class ExpenseTrackerPage extends StatefulWidget {
  const ExpenseTrackerPage({super.key});

  @override
  State<ExpenseTrackerPage> createState() => _ExpenseTrackerPageState();
}

class _ExpenseTrackerPageState extends State<ExpenseTrackerPage> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  final TextEditingController _transportController = TextEditingController();
  final TextEditingController _foodController = TextEditingController();
  final TextEditingController _shoppingController = TextEditingController();
  final TextEditingController _otherController = TextEditingController();

  final Map<String, TextEditingController> customExpenseControllers = {};

  @override
  void initState() {
    super.initState();
    _loadExpenses();
  }

  Future<void> _loadExpenses() async {
    final user = _auth.currentUser;
    if (user != null) {
      final doc = await _firestore.collection('expenses').doc(user.uid).get();
      if (doc.exists) {
        final data = doc.data();
        if (data != null) {
          setState(() {
            _transportController.text = data['categories']['transport']?.toString() ?? '';
            _foodController.text = data['categories']['food']?.toString() ?? '';
            _shoppingController.text = data['categories']['shopping']?.toString() ?? '';
            _otherController.text = data['categories']['otherCosts']?.toString() ?? '';
            if (data['customCategories'] != null) {
              final customCategories = Map<String, dynamic>.from(data['customCategories']);
              customCategories.forEach((key, value) {
                customExpenseControllers[key] = TextEditingController(text: value.toString());
              });
            }
          });
        }
      }
    }
  }

  Future<void> _saveExpenses() async {
    final user = _auth.currentUser;
    if (user != null) {
      final expenses = {
        "categories": {
          "transport": double.tryParse(_transportController.text) ?? 0.0,
          "food": double.tryParse(_foodController.text) ?? 0.0,
          "shopping": double.tryParse(_shoppingController.text) ?? 0.0,
          "otherCosts": double.tryParse(_otherController.text) ?? 0.0,
        },
        "customCategories": {}
      };

      customExpenseControllers.forEach((key, controller) {
        expenses["customCategories"]?[key] = double.tryParse(controller.text) ?? 0.0;
      });

      await _firestore.collection('expenses').doc(user.uid).set(expenses);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Expenses Saved Successfully')),
      );
    }
  }

  void _addCustomExpense(String category) {
    if (customExpenseControllers.containsKey(category)) return;

    customExpenseControllers[category] = TextEditingController();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Expense Tracker"),
        actions: [
          IconButton(
            icon: const Icon(Icons.home),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const Dashboard()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Categorize Your Expenses',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              buildExpenseInputField(context, "Transport", Icons.directions_bus, _transportController),
              buildExpenseInputField(context, "Food", Icons.fastfood, _foodController),
              buildExpenseInputField(context, "Shopping", Icons.shopping_cart, _shoppingController),
              buildExpenseInputField(context, "Other Costs", Icons.miscellaneous_services, _otherController),
              const SizedBox(height: 20),

              const Text(
                'Custom Expenses:',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              ...customExpenseControllers.entries.map((entry) {
                String category = entry.key;
                TextEditingController controller = entry.value;
                return Card(
                  elevation: 5,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: TextField(
                            controller: controller,
                            decoration: InputDecoration(
                              labelText: category,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => _removeCustomExpense(category),
                        ),
                      ],
                    ),
                  ),
                );
              }),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      final TextEditingController customCategoryController = TextEditingController();
                      return AlertDialog(
                        title: const Text('Add Custom Expense'),
                        content: TextField(
                          controller: customCategoryController,
                          decoration: const InputDecoration(labelText: 'Enter Custom Category'),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              String category = customCategoryController.text.trim();
                              if (category.isNotEmpty) _addCustomExpense(category);
                              Navigator.of(context).pop();
                            },
                            child: const Text('Add'),
                          ),
                        ],
                      );
                    },
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text("Add Custom Expense"),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveExpenses,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text("Save Expenses"),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const Dashboard()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text("Go to Dashboard"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildExpenseInputField(BuildContext context, String label, IconData icon, TextEditingController controller) {
    return Card(
      elevation: 5,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: label,
            prefixIcon: Icon(icon, color: Theme.of(context).primaryColor),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          keyboardType: TextInputType.number,
        ),
      ),
    );
  }

  Future<void> _removeCustomExpense(String category) async {
    final user = _auth.currentUser;
    if (user != null) {
      final doc = await _firestore.collection('expenses').doc(user.uid).get();
      if (doc.exists) {
        final data = doc.data();
        if (data != null && data['customCategories'] != null) {
          final customCategories = Map<String, dynamic>.from(data['customCategories']);
          customCategories.remove(category);
          await _firestore.collection('expenses').doc(user.uid).update({
            'customCategories': customCategories,
          });
        }
      }
    }
    setState(() {
      customExpenseControllers[category]?.dispose();
      customExpenseControllers.remove(category);
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Custom expense "$category" removed')));
  }

  @override
  void dispose() {
    _transportController.dispose();
    _foodController.dispose();
    _shoppingController.dispose();
    _otherController.dispose();
    customExpenseControllers.forEach((key, controller) => controller.dispose());
    super.dispose();
  }
}











