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
  List<double> monthlyExpenses = List.generate(6, (index) => 0); // Last 6 months expenses
  List<String> months = [];

  @override
  void initState() {
    super.initState();
    fetchUserData();
    fetchMonthlyExpenses();
  }

  Future<void> fetchUserData() async {
    final response = await http.get(Uri.parse('http://localhost:8000/get/user/66bc64aa9eef5c744dfe0c93'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final user = data['user'];

      setState(() {
        name = user['username'];
        email = user['email'];
        mobile = user['phone'];
        totalExpenses = user['expenses'].where((e) => DateTime.parse(e['date']).month == DateTime.now().month).fold(0.0, (sum, e) => sum + e['amount']);
      });
    } else {
      // Handle error
      throw Exception('Failed to load user data');
    }
  }

  Future<void> fetchMonthlyExpenses() async {
    final response = await http.post(
      Uri.parse('http://localhost:8000/monthly/expense'),
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
        final monthName = DateTime.now().month == date.month ? 'Current Month' : date.toLocal().month.toString();

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
      // Handle error
      throw Exception('Failed to load monthly expenses');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900], 
      drawer: const SideBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // const Center(
                //   child: CircleAvatar(
                //     radius: 50,
                //     backgroundImage: AssetImage('assets/profile_picture.png'), // Add a profile picture
                //   ),
                // ),
                const SizedBox(height: 20),
                _buildProfileCard(),
                const SizedBox(height: 20),
                _buildExpensesCard(),
                const SizedBox(height: 20),
                _buildMonthlyExpensesCard(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileCard() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      color: Colors.white.withOpacity(0.1),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              name,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              email,
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[400],
              ),
            ),
            const SizedBox(height: 10),
            Text(
              mobile,
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[400],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpensesCard() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      color: Colors.white.withOpacity(0.1),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
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
                color: Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthlyExpensesCard() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      color: Colors.white.withOpacity(0.1),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
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
                  months: months),
            ),
          ],
        ),
      ),
    );
  }
}
