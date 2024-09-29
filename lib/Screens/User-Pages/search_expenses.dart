// ignore_for_file: avoid_print, unused_element

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../SidebarMenu/side_bar.dart';
import '../../models/expense.dart';
import '../../modals/add_expense_modal.dart';

class SearchExpensePage extends StatefulWidget {
  const SearchExpensePage({super.key});

  @override
  _SearchExpensePageState createState() => _SearchExpensePageState();
}

class _SearchExpensePageState extends State<SearchExpensePage> {
  List<Expense> _expenses = [];
  List<Expense> _filteredExpenses = [];
  Map<String, String> _categoryNames = {}; // Map to cache category names
  bool _isLoading = true;
  bool _hasExpenses = true; // Flag to determine if expenses exist
  final String _userId = '66bc64aa9eef5c744dfe0c93'; // Your user ID
  String _searchQuery = '';
  String? _selectedCategory;
  String? _selectedMonth;

  @override
  void initState() {
    super.initState();
    _fetchCategoriesAndExpenses();
  }

  Future<void> _fetchCategoriesAndExpenses() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final userResponse =
          await http.get(Uri.parse('http://localhost:8000/get/user/$_userId'));
      if (userResponse.statusCode == 200) {
        final userData = jsonDecode(userResponse.body);
        final List<dynamic> categoriesData = userData['user']['categories'];

        // Fetch category names
        for (var categoryJson in categoriesData) {
          final categoryId = categoryJson['_id'];
          final categoryName = categoryJson['categoryName'];
          _categoryNames[categoryId] = categoryName;
        }

        // Fetch all expenses
        final expensesResponse = await http
            .get(Uri.parse('http://localhost:8000/get/user/$_userId'));
        if (expensesResponse.statusCode == 200) {
          final expensesData = jsonDecode(expensesResponse.body);
          final List<dynamic> expensesList = expensesData['user']['expenses'];

          setState(() {
            _expenses =
                expensesList.map((json) => Expense.fromJson(json)).toList();
            _filteredExpenses = _expenses;
            _isLoading = false;
            _hasExpenses = _filteredExpenses.isNotEmpty; // Set the flag
          });
        } else {
          throw Exception('Failed to load expenses');
        }
      } else {
        throw Exception('Failed to load user data');
      }
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
      print(error);
    }
  }

  void _sortByCategory(String? categoryId) {
    setState(() {
      _isLoading = true;
    });

    try {
      List<Expense> filteredByCategory = [];

      if (categoryId == null || categoryId.isEmpty) {
        // No category selected, use existing filtered expenses
        filteredByCategory = _filteredExpenses;
      } else {
        filteredByCategory = _expenses.where((expense) {
          return expense.category == categoryId;
        }).toList();
      }

      // Apply the month filter on top of category filter
      _filterByMonth(_selectedMonth, filteredByCategory);
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
      print(error);
    }
  }

  void _filterByMonth(String? month, [List<Expense>? expensesToFilter]) {
    setState(() {
      _selectedMonth = month;

      // Use the filtered expenses from previous filter or all expenses if not provided
      final expenses = expensesToFilter ?? _expenses;

      List<Expense> filteredByMonth;

      if (month == null || month.isEmpty) {
        filteredByMonth = expenses;
      } else {
        final selectedMonth = _monthToInt(month);
        filteredByMonth = expenses.where((expense) {
          final expenseMonth = expense.date.month;
          return expenseMonth == selectedMonth;
        }).toList();
      }

      _filteredExpenses = filteredByMonth;
      _hasExpenses = _filteredExpenses.isNotEmpty; // Update the flag
      _isLoading = false;
    });
  }

  int _monthToInt(String month) {
    switch (month) {
      case 'January':
        return 1;
      case 'February':
        return 2;
      case 'March':
        return 3;
      case 'April':
        return 4;
      case 'May':
        return 5;
      case 'June':
        return 6;
      case 'July':
        return 7;
      case 'August':
        return 8;
      case 'September':
        return 9;
      case 'October':
        return 10;
      case 'November':
        return 11;
      case 'December':
        return 12;
      default:
        return 0; // Default case if month is not recognized
    }
  }

  void _filterExpenses(String query) {
    setState(() {
      _searchQuery = query;
      _filteredExpenses = _filteredExpenses.where((expense) {
        return expense.label.toLowerCase().contains(query.toLowerCase());
      }).toList();
    });
  }

  void _openAddExpenseModal() async {
    final expense = await showDialog<Expense>(
      context: context,
      builder: (BuildContext context) => const AddExpenseModal(),
    );

    if (expense != null) {
      setState(() {
        _expenses.add(expense);
        _filterExpenses(_searchQuery); // Ensure the search filter is applied
      });
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
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate:
                    ExpenseSearchDelegate(_filteredExpenses, _filterExpenses),
              );
            },
          ),
          DropdownButton<String>(
            value: _selectedCategory,
            hint: const Text('Select Category'),
            items: _categoryNames.entries.map((entry) {
              return DropdownMenuItem<String>(
                value: entry.key,
                child: Text(entry.value),
              );
            }).toList(),
            onChanged: (categoryId) {
              setState(() {
                _selectedCategory = categoryId;
                _sortByCategory(categoryId);
              });
            },
          ),
          DropdownButton<String>(
            value: _selectedMonth,
            hint: const Text('Select Month'),
            items: [
              'January',
              'February',
              'March',
              'April',
              'May',
              'June',
              'July',
              'August',
              'September',
              'October',
              'November',
              'December'
            ].map((month) {
              return DropdownMenuItem<String>(
                value: month,
                child: Text(month),
              );
            }).toList(),
            onChanged: (month) {
              setState(() {
                _selectedMonth = month;
                _filterByMonth(month);
              });
            },
          ),
        ],
      ),
      drawer: const SideBar(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _hasExpenses
              ? Container(
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
                    itemCount: _filteredExpenses.length,
                    itemBuilder: (context, index) {
                      final expense = _filteredExpenses[index];
                      final categoryName =
                          _categoryNames[expense.category] ?? 'Unknown';

                      return Card(
                        color: Colors.white.withOpacity(0.1),
                        margin: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
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
                          onTap: () {
                            // Handle on tap if needed
                          },
                        ),
                      );
                    },
                  ),
                )
              : const Center(
                  child: Text(
                    'No expenses for this category or month.',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ),
    );
  }
}

class ExpenseSearchDelegate extends SearchDelegate {
  final List<Expense> expenses;
  final Function(String) onSearch;

  ExpenseSearchDelegate(this.expenses, this.onSearch);

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestions = expenses.where((expense) {
      return expense.label.toLowerCase().contains(query.toLowerCase());
    }).toList();

    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        final expense = suggestions[index];
        return ListTile(
          title: Text(expense.label),
          subtitle: Text('\$${expense.amount.toStringAsFixed(2)}'),
          onTap: () {
            query = expense.label;
            showResults(context);
          },
        );
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    onSearch(query);
    return Container(); // Just to trigger the search
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        Navigator.pop(context);
      },
    );
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
          showSuggestions(context);
        },
      ),
    ];
  }
}
