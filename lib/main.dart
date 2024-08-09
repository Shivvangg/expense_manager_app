import 'package:flutter/material.dart';

import 'Screens/User-Pages/expenses.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        primarySwatch: Colors.teal,
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const ExpenseListPage(),
        // '/searchExpense': (context) => SearchExpensePage(),
        // '/myProfile': (context) => MyProfilePage(),
        // '/expenses': (context) => ExpensesPage(),
        // '/repeatedExpense': (context) => RepeatedExpensePage(),
      },
    );
  }
}
