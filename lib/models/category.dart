// import 'dart:convert';

// Define the Expense class
class Category {
  final String id;
  final String categoryName;

  // Constructor
  Category({
    required this.id,
    required this.categoryName,
  });

  // Factory constructor to create an Expense from JSON
  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['_id'],
      categoryName: json['categoryName'],
    );
  }

  // Method to convert Expense to JSON
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'categoryName': categoryName,
    };
  }
}