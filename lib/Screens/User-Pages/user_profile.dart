// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:expense_manager/SidebarMenu/side_bar.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../Graphs/expenses_bar_chart.dart';

class UserProfile extends StatefulWidget {
  const UserProfile({super.key});

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  // User data
  String name = '';
  String email = '';
  String mobile = '';
  double totalExpenses = 0;
  List<double> monthlyExpenses =
      List.generate(6, (index) => 0); // Last 6 months expenses
  List<String> months = [];

  @override
  void initState() {
    super.initState();
    fetchUserData();
    fetchMonthlyExpenses();
  }

  Future<void> fetchUserData() async {
    try {
      final response = await http.get(
          Uri.parse('http://192.168.1.8:8000/get/user/66bc64aa9eef5c744dfe0c93'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final user = data['user'];
        setState(() {
          name = user['username'];
          email = user['email'];
          mobile = user['phone'];
          totalExpenses = user['expenses']
              .where((e) =>
                  DateTime.parse(e['date']).month == DateTime.now().month)
              .fold(0.0, (sum, e) => sum + e['amount']);
        });
      } else {
        throw Exception('Failed to load user data');
      }
    } catch (error) {
      print(error);
    }
  }

  Future<void> fetchMonthlyExpenses() async {
    try {
      final response = await http.post(
        Uri.parse('http://192.168.1.8:8000/monthly/expense'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'userId': '66bc64aa9eef5c744dfe0c93'}),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List;
        List<double> expenses = List.generate(6, (index) => 0.0);
        List<String> monthsList = List.generate(6, (index) => '');
        for (var item in data) {
          final month = item['month'];
          final totalAmount = item['totalAmount'];
          final DateTime date = DateTime.parse('$month-01');
          final monthName = DateTime.now().month == date.month
              ? 'Current Month'
              : _getMonthName(date.month);
          if (monthsList.contains(monthName)) {
            expenses[monthsList.indexOf(monthName)] = totalAmount;
          } else {
            monthsList.add(monthName);
            expenses.add(totalAmount);
          }
        }

        setState(() {
          monthlyExpenses = expenses;
          months = monthsList;
        });
      } else {
        throw Exception('Failed to load monthly expenses');
      }
    } catch (error) {
      print(error);
    }
  }

  String _getMonthName(int monthNumber) {
    const List<String> monthNames = [
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
    ];
    return monthNames[monthNumber - 1];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Profile'),
        backgroundColor: Colors.deepPurple,
      ),
      drawer: const SideBar(),
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
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  // Center(
                  //   child: Column(
                  //     children: [
                  //       Text(
                  //         name.isNotEmpty ? name : 'Name',
                  //         style: const TextStyle(
                  //           fontSize: 28,
                  //           fontWeight: FontWeight.bold,
                  //           color: Colors.white,
                  //         ),
                  //       ),
                  //       const SizedBox(height: 10),
                  //       Text(
                  //         email.isNotEmpty ? email : 'Email',
                  //         style: TextStyle(
                  //           fontSize: 18,
                  //           color: Colors.grey[300],
                  //         ),
                  //       ),
                  //       const SizedBox(height: 10),
                  //       Text(
                  //         mobile.isNotEmpty ? mobile : 'Mobile',
                  //         style: TextStyle(
                  //           fontSize: 18,
                  //           color: Colors.grey[300],
                  //         ),
                  //       ),
                  //     ],
                  //   ),
                  // ),
                  const SizedBox(height: 40),
                  Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10.0),
                      border: Border.all(color: Colors.grey.withOpacity(0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Total Expenses in Current Month:',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          '\$${totalExpenses.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.redAccent,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                  Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10.0),
                      border: Border.all(color: Colors.grey.withOpacity(0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Expenses for the Last 6 Months:',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          height: 300,
                          child: ExpensesBarChart(
                            monthlyExpenses: monthlyExpenses,
                            months: months,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
