import 'dart:convert';

// Define the Expense class
class Expense {
  final String id;
  final DateTime date;
  final String label;
  final String category;
  final double amount;
  final bool repeatable;

  // Constructor
  Expense({
    required this.id,
    required this.date,
    required this.label,
    required this.category,
    required this.amount,
    required this.repeatable,
  });

  // Factory constructor to create an Expense from JSON
  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: json['_id'],
      date: DateTime.parse(json['date']),
      label: json['label'],
      category: json['category'],
      amount: json['amount'].toDouble(),
      repeatable: json['repeatable'],
    );
  }

  // Method to convert Expense to JSON
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'date': date.toIso8601String(),
      'label': label,
      'category': category,
      'amount': amount,
      'repeatable': repeatable,
    };
  }
}