// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:expense_manager/SidebarMenu/side_bar.dart';
import 'package:expense_manager/modals/add_split_modal.dart';
import 'package:expense_manager/models/split.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
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
    }
  }

  Future<void> _fetchSplits() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response =
          await http.get(Uri.parse('http://192.168.1.8:8000/splits/$_userId'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> splitData = data['splits'];
        setState(() {
          _splits = splitData.map((json) => Splits.fromJson(json)).toList();
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load splits');
      }
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
      print(error);
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
                  final split = _splits[index];

                  final totalAmount = split.totalAmount;
                  final creatorId = split.creatorId;
                  final participants = split.participants;
                  final dateCreated = DateTime.parse(split.dateCreated);

                  return Dismissible(
                    key: Key(split.id + split.dateCreated.toString()),
                    onDismissed: (direction) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Split deleted'),
                        ),
                      );
                    },
                    background: Container(color: Colors.red),
                    child: Container(
                      width: MediaQuery.of(context).size.width - 5,
                      margin: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(
                            0.15), 
                        borderRadius:
                            BorderRadius.circular(12.0), 
                        boxShadow: [
                          BoxShadow(
                            color:
                                Colors.black.withOpacity(0.2),
                            spreadRadius: 2,
                            blurRadius: 6,
                            offset: const Offset(
                                0, 2), 
                          ),
                        ],
                        border: Border.all(
                            color: Colors.grey.withOpacity(0.5),
                            width: 1),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Creator: $creatorId',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            'Total Amount: \$${totalAmount.toStringAsFixed(2)}',
                            style: const TextStyle(
                              color: Colors
                                  .yellowAccent, 
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 10),

                          const Text(
                            'Participants:',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: participants.map<Widget>((participant) {
                              return Text(
                                '${participant.user.username} - \$${participant.splitAmount} (${participant.paid ? "Paid" : "Not Paid"})',
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Date Created: ${DateFormat('yyyy-MM-dd').format(dateCreated)}',
                            style: const TextStyle(
                              color: Colors.white54,
                              fontSize: 12,
                            ),
                          ),
                        ],
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
