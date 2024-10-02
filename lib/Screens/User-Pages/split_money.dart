// ignore_for_file: prefer_final_fields, unused_element, unused_local_variable, unused_field

import 'dart:convert';

import 'package:expense_manager/modals/add_split_modal.dart';
import 'package:expense_manager/models/split.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;


class SplitMoney extends StatefulWidget {
  const SplitMoney({super.key});

  @override
  State<SplitMoney> createState() => _SplitMoneyState();
}

class _SplitMoneyState extends State<SplitMoney> {
  List<Splits> _splits = [];
  bool _isLoading = true;

  void _openAddExpenseModal() async {
    final split = await showDialog<Splits>(
      context: context,
      builder: (BuildContext context) => const AddSplitModal(),
    );

    if (split != null) {
      _addSplit(split);
    }
  }

  void _addSplit(Splits split) {
    setState(() {
      _splits.add(split);
    });
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
          final split = Splits.fromJson(expenseJson);
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
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(onPressed: () {}),
    );
  }
}