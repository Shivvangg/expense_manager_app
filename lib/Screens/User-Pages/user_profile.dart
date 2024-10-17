// ignore_for_file: prefer_const_declarations

import 'package:flutter/material.dart';
import 'package:expense_manager/api_service.dart';
import '../../Graphs/expenses_bar_chart.dart';
import 'package:expense_manager/SidebarMenu/side_bar.dart';

class UserProfile extends StatefulWidget {
  const UserProfile({super.key});
  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  String name = '';
  String email = '';
  String mobile = '';
  double totalExpenses = 0;
  bool isEditingName = false;
  bool isEditingEmail = false;
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();

  List<double> monthlyExpenses = List.generate(6, (index) => 0); // Default to 0
  List<String> months =
      List.generate(6, (index) => _getMonthName(DateTime.now().month - index));

  @override
  void initState() {
    super.initState();
    fetchUserData();
    fetchMonthlyExpenses();
  }

  Future<void> fetchUserData() async {
    final userId =
        '66bc64aa9eef5c744dfe0c93'; 
    final data = await ApiService.fetchUserData(userId);
    if (data != null) {
      final user = data['user'];
      setState(() {
        name = user['username'];
        email = user['email'];
        mobile = user['phone'];
        nameController.text = name;
        emailController.text = email;
        totalExpenses = user['expenses']
            .where(
                (e) => DateTime.parse(e['date']).month == DateTime.now().month)
            .fold(0.0, (sum, e) => sum + e['amount']);
      });
    }
  }

  Future<void> fetchMonthlyExpenses() async {
    final userId =
        '66bc64aa9eef5c744dfe0c93'; 
    final expensesData = await ApiService.fetchMonthlyExpenses(userId);
    if (expensesData != null) {
      List<double> expenses = List.generate(6, (index) => 0.0);
      List<String> monthsList = List.generate(6, (index) => '');
      for (var item in expensesData) {
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
    }
  }

  Future<void> saveUserData() async {
    final userId =
        '66bc64aa9eef5c744dfe0c93'; 
    final success = await ApiService.updateUserData(
      userId,
      nameController.text,
      emailController.text,
    );
    if (success) {
      setState(() {
        name = nameController.text;
        email = emailController.text;
        isEditingName = false;
        isEditingEmail = false;
      });
    }
  }

  static String _getMonthName(int monthNumber) {
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
    return monthNames[(monthNumber - 1) % 12];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('User Profile'),
          backgroundColor: Colors.deepPurple,
        ),
        drawer: const SideBar(),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  _buildProfileInfoCard(),
                  const SizedBox(height: 40),
                  _buildCurrentMonthExpenses(),
                  const SizedBox(height: 40),
                  _buildLast6MonthsExpenses(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileInfoCard() {
    return Container(
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
            'User Details:',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 10),
          _buildEditableField('Name', nameController, isEditingName, () {
            setState(() {
              isEditingName = true;
            });
          }),
          const SizedBox(height: 10),
          _buildEditableField('Email', emailController, isEditingEmail, () {
            setState(() {
              isEditingEmail = true;
            });
          }),
          const SizedBox(height: 10),
          Text(
            'Mobile: $mobile',
            style: TextStyle(fontSize: 18, color: Colors.grey[300]),
          ),
          const SizedBox(height: 20),
          if (isEditingName || isEditingEmail)
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: saveUserData,
                  child: const Text('Save'),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      isEditingName = false;
                      isEditingEmail = false;
                      nameController.text = name;
                      emailController.text = email;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                  child: const Text('Cancel'),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildEditableField(String label, TextEditingController controller,
      bool isEditing, VoidCallback onEdit) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            readOnly: !isEditing,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: label,
              labelStyle: const TextStyle(color: Colors.grey),
              enabledBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.grey),
              ),
              focusedBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
              ),
            ),
          ),
        ),
        if (!isEditing)
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.white),
            onPressed: onEdit,
          ),
      ],
    );
  }

  Widget _buildCurrentMonthExpenses() {
    return Container(
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
    );
  }

  Widget _buildLast6MonthsExpenses() {
    return Container(
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
    );
  }
}
