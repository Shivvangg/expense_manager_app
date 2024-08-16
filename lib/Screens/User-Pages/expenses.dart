// ignore_for_file: avoid_print, prefer_final_fields, library_private_types_in_public_api

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../SidebarMenu/side_bar.dart';
import '../../models/expense.dart';
import 'add_expense_modal.dart';

class ExpenseListPage extends StatefulWidget {
  const ExpenseListPage({super.key});

  @override
  _ExpenseListPageState createState() => _ExpenseListPageState();
}

class _ExpenseListPageState extends State<ExpenseListPage> {
  List<Expense> _expenses = [];
  Map<String, String> _categoryNames = {}; // Map to cache category names
  bool _isLoading = true;
  final String _userId = '66bc64aa9eef5c744dfe0c93'; // Your user ID

  @override
  void initState() {
    super.initState();
    _fetchExpenses();
  }

  Future<void> _fetchExpenses() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.get(Uri.parse('http://localhost:8000/get/user/$_userId'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> expenseData = data['user']['expenses'];

        // Fetch category names
        for (var expenseJson in expenseData) {
          final expense = Expense.fromJson(expenseJson);
          if (!_categoryNames.containsKey(expense.category)) {
            await _fetchCategoryName(expense.category);
          }
        }

        setState(() {
          _expenses = expenseData.map((json) => Expense.fromJson(json)).toList();
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load expenses');
      }
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
      print(error);
    }
  }

  Future<void> _fetchCategoryName(String categoryId) async {
    try {
      final response = await http.get(Uri.parse('http://localhost:8000/get/category/$categoryId'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final categoryName = data['category']['categoryName'];

        setState(() {
          _categoryNames[categoryId] = categoryName;
        });
      } else {
        throw Exception('Failed to load category');
      }
    } catch (error) {
      print(error);
    }
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
      builder: (BuildContext context) => const AddExpenseModal(),
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
      drawer: const SideBar(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Container(
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
                  final categoryName = _categoryNames[expense.category] ?? 'Unknown';

                  return Dismissible(
                    key: Key(expense.id + expense.date.toString()),
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
                          '$categoryName - \$${expense.amount.toStringAsFixed(2)}',
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
