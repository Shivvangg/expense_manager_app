class Splits {
  final String id;
  final String creatorId; // User who created the split
  final double totalAmount; // Total amount of the split
  final List<Participant> participants; // List of participants and their split info
  final String? expenseId; // Expense linked to the split (optional)
  final bool settled; // Whether the split is settled
  final DateTime dateCreated;

  Splits({
    required this.id,
    required this.creatorId,
    required this.totalAmount,
    required this.participants,
    this.expenseId,
    required this.settled,
    required this.dateCreated,
  });

  // Factory method to parse JSON into Split object
  factory Splits.fromJson(Map<String, dynamic> json) {
    return Splits(
      id: json['_id'],
      creatorId: json['creatorId'],
      totalAmount: json['totalAmount'].toDouble(),
      participants: (json['participants'] as List)
          .map((participant) => Participant.fromJson(participant))
          .toList(),
      expenseId: json['expense'],
      settled: json['settled'],
      dateCreated: DateTime.parse(json['dateCreated']),
    );
  }

  // Method to convert Split object to JSON format
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'creatorId': creatorId,
      'totalAmount': totalAmount,
      'participants': participants.map((p) => p.toJson()).toList(),
      'expense': expenseId,
      'settled': settled,
      'dateCreated': dateCreated.toIso8601String(),
    };
  }
}

class Participant {
  final String userId; // User involved in the split
  final String userName; // Name of the user (optional for display purposes)
  final double splitAmount; // The amount this user owes or paid
  final bool paid; // If the user has paid their part

  Participant({
    required this.userId,
    required this.userName,
    required this.splitAmount,
    required this.paid,
  });

  // Factory method to parse JSON into Participant object
  factory Participant.fromJson(Map<String, dynamic> json) {
    return Participant(
      userId: json['user'],
      userName: json['userName'], // Optional field for display purposes
      splitAmount: json['splitAmount'].toDouble(),
      paid: json['paid'],
    );
  }

  // Method to convert Participant object to JSON format
  Map<String, dynamic> toJson() {
    return {
      'user': userId,
      'userName': userName, // Optional
      'splitAmount': splitAmount,
      'paid': paid,
    };
  }
}
