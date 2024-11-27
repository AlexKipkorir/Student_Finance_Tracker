import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'dashboard.dart'; // Make sure this import is present

class BillRemindersPage extends StatefulWidget {
  const BillRemindersPage({super.key, required String housingBudget, required String dueDate});

  @override
  State<BillRemindersPage> createState() => _BillRemindersPageState();
}

class _BillRemindersPageState extends State<BillRemindersPage> {
  final TextEditingController _billNameController = TextEditingController();
  final TextEditingController _billAmountController = TextEditingController();
  DateTime? _dueDate;

  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    tz.initializeTimeZones();
    _initializeNotifications();
  }

  void _initializeNotifications() {
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings =
    InitializationSettings(android: initializationSettingsAndroid);

    _notificationsPlugin.initialize(initializationSettings);
  }

  Future<void> _scheduleNotification(DateTime scheduledTime) async {
    final tz.TZDateTime tzDateTime = tz.TZDateTime.from(scheduledTime, tz.local);

    const AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails(
      'bill_reminder_channel',
      'Bill Reminders',
      importance: Importance.high,
      priority: Priority.high,
    );

    const NotificationDetails platformChannelSpecifics =
    NotificationDetails(android: androidPlatformChannelSpecifics);

    await _notificationsPlugin.zonedSchedule(
      0,
      'Bill Due',
      'Your bill "${_billNameController.text}" is due soon!',
      tzDateTime,
      platformChannelSpecifics,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.wallClockTime,
    );
  }

  Future<void> _addBillReminder() async {
    final String name = _billNameController.text.trim();
    final double? amount = double.tryParse(_billAmountController.text.trim());
    if (name.isNotEmpty && amount != null && _dueDate != null) {
      final billData = {
        'name': name,
        'amount': amount,
        'dueDate': Timestamp.fromDate(_dueDate!),
        'userId': FirebaseAuth.instance.currentUser?.uid ?? 'defaultUserId',
      };

      try {
        await FirebaseFirestore.instance.collection('bills').add(billData);
        _scheduleNotification(_dueDate!);
        _billNameController.clear();
        _billAmountController.clear();
        setState(() {
          _dueDate = null;
        });
        Navigator.pop(context); // This returns to the previous screen
      } catch (e) {
        debugPrint("Error adding bill to Firestore: $e");
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill in all fields with valid data")),
      );
    }
  }

  Future<void> _selectDueDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null) {
      setState(() {
        _dueDate = pickedDate;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bill Reminders')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () => _showAddBillDialog(context),
              child: const Text('Add Bill Reminder'),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('bills')
                    .where('userId', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return const Center(child: Text('Error loading bills'));
                  }
                  final bills = snapshot.data?.docs ?? [];
                  if (bills.isEmpty) {
                    return const Center(child: Text('No bill reminders found.'));
                  }
                  return ListView.builder(
                    itemCount: bills.length,
                    itemBuilder: (context, index) {
                      final bill = bills[index].data() as Map<String, dynamic>;
                      final dueDate = (bill['dueDate'] as Timestamp).toDate();
                      return Card(
                        child: ListTile(
                          title: Text(bill['name']),
                          subtitle: Text(
                            'Amount: Ksh${bill['amount'].toStringAsFixed(2)}\nDue: ${DateFormat.yMMMd().format(dueDate)}',
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            ElevatedButton(
              onPressed: _clearAllReminders,
              child: const Text('Clear All Reminders'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const Dashboard()), // Corrected navigation
                );
              },
              child: const Text('Go Back to Dashboard'),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddBillDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Bill Reminder'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _billNameController,
                decoration: const InputDecoration(hintText: 'Bill Name'),
              ),
              TextField(
                controller: _billAmountController,
                decoration: const InputDecoration(hintText: 'Amount'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () => _selectDueDate(context),
                child: Text(_dueDate == null
                    ? 'Pick Due Date'
                    : 'Due Date: ${DateFormat.yMMMd().format(_dueDate!)}'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: _addBillReminder,
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _clearAllReminders() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      try {
        final snapshot = await FirebaseFirestore.instance
            .collection('bills')
            .where('userId', isEqualTo: userId)
            .get();
        for (var doc in snapshot.docs) {
          await doc.reference.delete();
        }
      } catch (e) {
        debugPrint("Error clearing reminders: $e");
      }
    }
  }
}



