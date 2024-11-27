import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dashboard.dart';

class InvestmentTrackingPage extends StatelessWidget {
  const InvestmentTrackingPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Investment Tracking"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const Dashboard()),
            );
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Monitor Your Investments",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              "Keep track of your assets and portfolio performance with ease.",
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),

            // Investment Summary Section from Firestore
            buildInvestmentSummary(),

            const SizedBox(height: 20),

            // Add Investment Button
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // Show dialog to add a new investment
                  showAddInvestmentDialog(context);
                },
                child: const Text("Add Investment"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget to display investment summary from Firestore
  Widget buildInvestmentSummary() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('investments')
          .where('userId', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return const Center(child: Text('Error loading investments'));
        }

        final investments = snapshot.data?.docs ?? [];

        return Column(
          children: investments.map((doc) {
            final investment = doc.data() as Map<String, dynamic>;
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 10),
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: ListTile(
                title: Text(
                  investment['name'],
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  "Amount: Ksh${(investment['amount'] as double).toStringAsFixed(2)}\n"
                      "Performance: ${investment['performance']}%",
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  // Function to show dialog for adding a new investment
  void showAddInvestmentDialog(BuildContext context) {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController amountController = TextEditingController();
    final TextEditingController performanceController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Add New Investment"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: "Investment Name"),
              ),
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Amount"),
              ),
              TextField(
                controller: performanceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Performance (%)"),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                if (nameController.text.isNotEmpty &&
                    amountController.text.isNotEmpty &&
                    performanceController.text.isNotEmpty) {
                  await _addInvestmentToFirestore(
                    nameController.text,
                    double.parse(amountController.text),
                    double.parse(performanceController.text),
                  );
                  Navigator.of(context).pop(); // Close the dialog
                }
              },
              child: const Text("Save"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text("Cancel"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _addInvestmentToFirestore(
      String name, double amount, double performance) async {
    final userId = FirebaseAuth.instance.currentUser?.uid ?? 'defaultUserId';
    final investmentData = {
      'name': name,
      'amount': amount,
      'performance': performance,
      'userId': userId,
    };

    try {
      await FirebaseFirestore.instance.collection('investments').add(investmentData);
    } catch (e) {
      debugPrint("Error adding investment to Firestore: $e");
    }
  }
}


