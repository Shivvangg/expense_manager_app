import 'package:flutter/material.dart';

import 'Screens/User-Pages/expenses.dart';
import 'Screens/User-Pages/search_expenses.dart';
import 'package:expense_manager/Screens/User-Pages/user_profile.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        primarySwatch: Colors.teal,
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const ExpenseListPage(),
        '/searchExpense': (context) => const SearchExpensePage(),
        '/myProfile': (context) => const UserProfile(),
        // '/mySplite': (context) => const MySplitPage(),
      },
    );
  }
}
