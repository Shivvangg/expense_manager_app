// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:http/http.dart' as http;

import 'models/expense.dart';

class ApiService {
  static const String baseUrl = 'http://192.168.1.8:8000';

  static Future<Map<String, dynamic>?> fetchUserData(String userId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/get/user/$userId'));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load user data');
      }
    } catch (error) {
      print('Error fetching user data: $error');
      return null;
    }
  }

  static Future<List<dynamic>?> fetchMonthlyExpenses(String userId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/monthly/expense'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'userId': userId}),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load monthly expenses');
      }
    } catch (error) {
      print('Error fetching monthly expenses: $error');
      return null;
    }
  }

  static Future<bool> updateUserData(String userId, String username, String email) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/update/user'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': userId,
          'username': username,
          'email': email,
        }),
      );
      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception('Failed to update user data');
      }
    } catch (error) {
      print('Error updating user data: $error');
      return false;
    }
  }

  static Future<Map<String, dynamic>?> fetchCategoriesAndExpenses(String userId) async {
    try {
      final userResponse = await http.get(Uri.parse('$baseUrl/get/user/$userId'));
      if (userResponse.statusCode == 200) {
        final userData = jsonDecode(userResponse.body);
        return userData;
      } else {
        throw Exception('Failed to load user data');
      }
    } catch (error) {
      print('Error fetching user data: $error');
      return null;
    }
  }

  static Future<List<Expense>?> fetchUserExpenses(String userId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/get/user/$userId'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> expensesData = data['user']['expenses'];
        return expensesData.map((json) => Expense.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load user expenses');
      }
    } catch (error) {
      print('Error fetching user expenses: $error');
      return null;
    }
  }

  static Future<String?> fetchCategoryName(String categoryId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/get/category/$categoryId'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['category']['categoryName'];
      } else {
        throw Exception('Failed to load category');
      }
    } catch (error) {
      print('Error fetching category: $error');
      return null;
    }
  }
}
