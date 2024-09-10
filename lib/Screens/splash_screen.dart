// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Import SharedPreferences

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkToken();
  }

  Future<void> _checkToken() async {
    // Retrieve the token from shared preferences
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    
    // Navigate based on whether the token exists
    SchedulerBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(seconds: 3), () {
        if (token != null) {
          // Navigate to the main screen and remove all previous routes
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/expense-screen',
            (Route<dynamic> route) => false, // Remove all previous routes
          );
        } else {
          // Navigate to the login screen and remove all previous routes
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/login',
            (Route<dynamic> route) => false, // Remove all previous routes
          );
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF1E1F24), // Start color (example, adjust to match your image)
              Color(0xFF3A3F44), // End color (example, adjust to match your image)
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Image.asset(
            'assets/images/skill_link-logo1.png',
            // Adjust the logo size if needed
            width: 150,
            height: 150,
          ),
        ),
      ),
    );
  }
}
