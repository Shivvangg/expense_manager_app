// ignore_for_file: unused_import

import 'package:expense_manager/Screens/Auth/login_screen.dart';
import 'package:flutter/material.dart';

import 'Screens/User-Pages/expenses.dart';
import 'Screens/User-Pages/search_expenses.dart';
import 'package:expense_manager/Screens/User-Pages/user_profile.dart';

import 'Screens/splash_screen.dart';

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
        '/': (context) => const SplashScreen(),
        '/searchExpense': (context) => const SearchExpensePage(),
        '/myProfile': (context) => const UserProfile(),
        '/login': (context) => const LoginScreen(),
        '/expense-screen': (context) => const ExpenseListPage(),
        // '/mySplite': (context) => const MySplitPage(),
      },
    );
  }
}
