// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';

import '../../models/expense.dart';
import 'add_expense_modal.dart';

class ExpenseListPage extends StatefulWidget {
  const ExpenseListPage({super.key});

  @override
  _ExpenseListPageState createState() => _ExpenseListPageState();
}

class _ExpenseListPageState extends State<ExpenseListPage> {
  List<Expense> _expenses = [];

  @override
  void initState() {
    super.initState();
    _addDummyExpenses();
  }

  void _addDummyExpenses() {
    _expenses = [
      Expense(
        category: 'Food',
        label: 'Lunch at Cafe',
        amount: 15.99,
        repeatable: false,
        date: DateTime.now().subtract(const Duration(days: 1)),
      ),
      Expense(
        category: 'Travel',
        label: 'Taxi to Airport',
        amount: 45.00,
        repeatable: false,
        date: DateTime.now().subtract(const Duration(days: 3)),
      ),
    ];
  }

  void _addExpense(Expense expense) {
    setState(() {
      _expenses.add(expense);
    });
  }

  void _deleteExpense(int index) {
    setState(() {
      _expenses.removeAt(index);
    });
  }

  void _openAddExpenseModal() async {
    final expense = await showDialog<Expense>(
      context: context,
      builder: (BuildContext context) => AddExpenseModal(),
    );

    if (expense != null) {
      _addExpense(expense);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Expenses'),
        backgroundColor: Colors.deepPurple,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _openAddExpenseModal,
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.deepPurple,
              Colors.black,
            ],
          ),
        ),
        child: ListView.builder(
          itemCount: _expenses.length,
          itemBuilder: (context, index) {
            final expense = _expenses[index];
            return Dismissible(
              key: Key(expense.label + expense.date.toString()),
              onDismissed: (direction) {
                _deleteExpense(index);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${expense.label} deleted'),
                  ),
                );
              },
              background: Container(color: Colors.red),
              child: Card(
                color: Colors.white.withOpacity(0.1),
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                elevation: 5,
                child: ListTile(
                  title: Text(
                    expense.label,
                    style: const TextStyle(color: Colors.white),
                  ),
                  subtitle: Text(
                    '${expense.category} - \$${expense.amount.toStringAsFixed(2)}',
                    style: const TextStyle(color: Colors.white70),
                  ),
                  trailing: Text(
                    '${expense.date.toLocal()}'.split(' ')[0],
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openAddExpenseModal,
        backgroundColor: Colors.deepPurple,
        child: const Icon(Icons.add),
      ),
    );
  }
}
