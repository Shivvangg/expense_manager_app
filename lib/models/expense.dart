class Expense {
  final String category;
  final String label;
  final double amount;
  final bool repeatable;
  final DateTime date;

  Expense({
    required this.category,
    required this.label,
    required this.amount,
    required this.repeatable,
    required this.date,
  });

  @override
  String toString() {
    return 'Expense(category: $category, label: $label, amount: $amount, repeatable: $repeatable, date: $date)';
  }
}
