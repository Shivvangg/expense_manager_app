// ignore_for_file: prefer_final_fields, unused_element, unused_local_variable, unused_field, avoid_print

import 'dart:convert';

import 'package:expense_manager/SidebarMenu/side_bar.dart';
import 'package:expense_manager/modals/add_split_modal.dart';
import 'package:expense_manager/models/split.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class SplitMoney extends StatefulWidget {
  const SplitMoney({super.key});

  @override
  State<SplitMoney> createState() => _SplitMoneyState();
}

class _SplitMoneyState extends State<SplitMoney> {
  List<Splits> _splits = [];
  bool _isLoading = true;
  String? _userId;

  @override
  void initState() {
    super.initState();
    _getUserIdAndFetchSplits();
  }

  Future<void> _getUserIdAndFetchSplits() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('user_id');

    if (userId != null) {
      setState(() {
        _userId = userId;
      });
      _fetchSplits();
    } else {
      print('User ID not found');
      // Optionally handle navigation to login
    }
  }

  void _openAddSplitModal() async {
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

  Future<void> _fetchSplits() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response =
          await http.get(Uri.parse('http://localhost:8000/splits/$_userId'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> splitData = data['splits'];
        print(splitData);

        // Fetch category names
        for (var expenseJson in splitData) {
          final split = Splits.fromJson(expenseJson);
        }

        setState(() {
          _splits = splitData.map((json) => Splits.fromJson(json)).toList();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Splits"),
        backgroundColor: Colors.deepPurple,
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
                itemCount: _splits.length,
                itemBuilder: (context, index) {
                  final spplit = _splits[index];
                  // final categoryName =
                  //     _categoryNames[expense.category] ?? 'Unknown';

                  return Dismissible(
                    key: Key(spplit.id + spplit.dateCreated.toString()),
                    onDismissed: (direction) {
                      // _deleteExpense(index);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('split deleted'),
                        ),
                      );
                    },
                    background: Container(color: Colors.red),
                    child: Card(
                      color: Colors.white.withOpacity(0.1),
                      margin: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      elevation: 5,
                      child: ListTile(
                        title: Text(
                          spplit.creatorId,
                          style: const TextStyle(color: Colors.white),
                        ),
                        subtitle: const Text(
                          'testing',
                          style:  TextStyle(color: Colors.white70),
                        ),
                        trailing: Text(
                          '${spplit.dateCreated.toLocal()}'.split(' ')[0],
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openAddSplitModal,
        backgroundColor: Colors.deepPurple,
        child: const Icon(Icons.add),
      ),
    );
  }
}
