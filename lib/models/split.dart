class Splits {
  final String id;
  final double amount;
  final String payerId;
  final String payerName; // Optional, if you want to display payer name
  final List<UserShare> participants; // List of participants and their share
  final DateTime date;

  Splits({
    required this.id,
    required this.amount,
    required this.payerId,
    required this.payerName,
    required this.participants,
    required this.date,
  });

  // Function to parse JSON response and create a Split object
  factory Splits.fromJson(Map<String, dynamic> json) {
    return Splits(
      id: json['_id'],
      amount: json['amount'].toDouble(),
      payerId: json['payerId'],
      payerName: json['payerName'], // Optional, if provided by backend
      participants: (json['participants'] as List)
          .map((participant) => UserShare.fromJson(participant))
          .toList(),
      date: DateTime.parse(json['date']),
    );
  }

  // Function to convert Split object to JSON format
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'payerId': payerId,
      'payerName': payerName, // Optional
      'participants': participants.map((participant) => participant.toJson()).toList(),
      'date': date.toIso8601String(),
    };
  }
}

class UserShare {
  final String userId;
  final String userName;
  final double amountPaid;

  UserShare({
    required this.userId,
    required this.userName,
    required this.amountPaid,
  });

  // Function to parse JSON response and create a UserShare object
  factory UserShare.fromJson(Map<String, dynamic> json) {
    return UserShare(
      userId: json['userId'],
      userName: json['userName'],
      amountPaid: json['amountPaid'].toDouble(),
    );
  }

  // Function to convert UserShare object to JSON format
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'userName': userName,
      'amountPaid': amountPaid,
    };
  }
}
