class SplitResponse {
  final String message;
  final List<Splits> splits;

  SplitResponse({required this.message, required this.splits});

  factory SplitResponse.fromJson(Map<String, dynamic> json) {
    return SplitResponse(
      message: json['message'],
      splits: List<Splits>.from(json['splits'].map((x) => Splits.fromJson(x))),
    );
  }
}

class Splits {
  final String id;
  final String creatorId;
  final int totalAmount;
  final List<Participant> participants;
  final bool settled;
  final String dateCreated;

  Splits({
    required this.id,
    required this.creatorId,
    required this.totalAmount,
    required this.participants,
    required this.settled,
    required this.dateCreated,
  });

  factory Splits.fromJson(Map<String, dynamic> json) {
    return Splits(
      id: json['_id'],
      creatorId: json['creatorId'],
      totalAmount: json['totalAmount'],
      participants: List<Participant>.from(json['participants'].map((x) => Participant.fromJson(x))),
      settled: json['settled'],
      dateCreated: json['dateCreated'],
    );
  }
}

class Participant {
  final User user;
  final int splitAmount;
  final bool paid;
  final String id;

  Participant({
    required this.user,
    required this.splitAmount,
    required this.paid,
    required this.id,
  });

  factory Participant.fromJson(Map<String, dynamic> json) {
    return Participant(
      user: User.fromJson(json['user']),
      splitAmount: json['splitAmount'],
      paid: json['paid'],
      id: json['_id'],
    );
  }
}

class User {
  final String id;
  final String email;
  final String username;
  final String phone;
  final String password;
  final List<String> categories;
  final List<String> expenses;

  User({
    required this.id,
    required this.email,
    required this.username,
    required this.phone,
    required this.password,
    required this.categories,
    required this.expenses,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'],
      email: json['email'],
      username: json['username'],
      phone: json['phone'],
      password: json['password'],
      categories: List<String>.from(json['categories']),
      expenses: List<String>.from(json['expenses']),
    );
  }
}
