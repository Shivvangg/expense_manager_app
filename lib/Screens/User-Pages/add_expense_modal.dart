// ignore_for_file: prefer_final_fields, library_private_types_in_public_api, unused_field, use_build_context_synchronously, avoid_print

import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../models/expense.dart';

class AddExpenseModal extends StatefulWidget {
  const AddExpenseModal({super.key});

  @override
  _AddExpenseModalState createState() => _AddExpenseModalState();
}

class _AddExpenseModalState extends State<AddExpenseModal> {
  String _selectedCategoryId = '';
  String _selectedCategoryName = 'Select Category';
  List<Map<String, String>> _categories = [];
  double _amount = 0.0;
  bool _repeatable = false;
  DateTime _selectedDate = DateTime.now();
  final TextEditingController _labelController = TextEditingController();
  final String _userId = '66bc64aa9eef5c744dfe0c93'; // Your user ID

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    try {
      final response =
          await http.get(Uri.parse('http://localhost:8000/get/user/$_userId'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> categoriesData = data['user']['categories'];

        setState(() {
          _categories = categoriesData.map((dynamic item) {
            final category = item as Map<String, dynamic>;
            return {
              'id': category['_id'] as String,
              'name': category['categoryName'] as String,
            };
          }).toList();

          if (_categories.isNotEmpty) {
            _selectedCategoryId = _categories[0]['id']!;
            _selectedCategoryName = _categories[0]['name']!;
          }
        });
      } else {
        throw Exception('Failed to load categories');
      }
    } catch (error) {
      print(error);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load categories')),
      );
    }
  }

  void _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2050),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Colors.deepPurple,
              onPrimary: Colors.white,
            ),
            dialogBackgroundColor: Colors.black,
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _addCategory() {
    setState(() {
      _categories.add({'id': 'new_id', 'name': 'New Category'});
      _selectedCategoryId = 'new_id';
      _selectedCategoryName = 'New Category';
    });
  }

  Future<void> _saveExpense() async {
    final expense = Expense(
      category: _selectedCategoryId,
      label: _labelController.text,
      amount: _amount,
      repeatable: _repeatable,
      date: _selectedDate,
      id: '', // ID will be generated by the backend
    );

    try {
      final response = await http.post(
        Uri.parse('http://localhost:8000/add/newExpense'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'date': expense.date.toIso8601String(),
          'label': expense.label,
          'category': expense.category,
          'amount': expense.amount,
          'repeatable': expense.repeatable,
          'userId': _userId,
        }),
      );

      if (response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        final newExpense = Expense.fromJson(responseData['expense']);

        Navigator.of(context).pop(newExpense);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Expense added successfully')),
        );
      } else {
        throw Exception('Failed to add expense');
      }
    } catch (error) {
      print(error);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to add expense')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.deepPurple,
              Colors.black,
            ],
          ),
          borderRadius: BorderRadius.circular(8.0),
          boxShadow: [
            BoxShadow(
              color: Colors.deepPurple.withOpacity(0.5),
              spreadRadius: 3,
              blurRadius: 7,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const Text(
                'Add Expense',
                style: TextStyle(color: Colors.white, fontSize: 20),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Category',
                  labelStyle: TextStyle(color: Colors.white),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                ),
                dropdownColor: Colors.black,
                value:
                    _selectedCategoryId.isNotEmpty ? _selectedCategoryId : null,
                items: _categories.map((category) {
                  return DropdownMenuItem<String>(
                    value: category['id'],
                    child: Text(category['name']!,
                        style: const TextStyle(color: Colors.white)),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategoryId = value!;
                    _selectedCategoryName = _categories.firstWhere(
                        (category) => category['id'] == value)['name']!;
                  });
                },
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _labelController,
                decoration: const InputDecoration(
                  labelText: 'Label',
                  labelStyle: TextStyle(color: Colors.white),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                ),
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 12),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Amount',
                  labelStyle: TextStyle(color: Colors.white),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                ),
                style: const TextStyle(color: Colors.white),
                keyboardType: TextInputType.number,
                onChanged: (value) => _amount = double.tryParse(value) ?? 0.0,
              ),
              const SizedBox(height: 12),
              Row(
                children: <Widget>[
                  const Text(
                    'Repeatable',
                    style: TextStyle(color: Colors.white),
                  ),
                  const SizedBox(width: 8),
                  CupertinoSwitch(
                    value: _repeatable,
                    onChanged: (value) {
                      setState(() {
                        _repeatable = value;
                      });
                    },
                  ),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: _addCategory,
                    child: const Text('Add Category'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () => _selectDate(context),
                child: Row(
                  children: <Widget>[
                    const Icon(Icons.calendar_today, color: Colors.white),
                    const SizedBox(width: 8),
                    Text(
                      '${_selectedDate.toLocal()}'.split(' ')[0],
                      style: const TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _saveExpense,
                child: const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
