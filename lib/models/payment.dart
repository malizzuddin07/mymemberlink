class Payment {
  final int id;
  final int membershipId;
  final int userId;
  final DateTime purchaseDate;
  final double amount;
  final String paymentStatus;
  final String membershipName;

  Payment({
    required this.id,
    required this.membershipId,
    required this.userId,
    required this.purchaseDate,
    required this.amount,
    required this.paymentStatus,
    required this.membershipName,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id'].toString()) ?? 0,
      membershipId: json['membership_id'] is int
          ? json['membership_id']
          : int.tryParse(json['membership_id'].toString()) ?? 0,
      userId: json['user_id'] is int
          ? json['user_id']
          : int.tryParse(json['user_id'].toString()) ?? 0,
      purchaseDate: DateTime.parse(json['purchase_date']),
      amount: json['amount'] is double
          ? json['amount']
          : double.tryParse(json['amount'].toString()) ?? 0.0,
      paymentStatus: json['payment_status'] ?? 'Pending',
      membershipName: json['membership_name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'membership_id': membershipId,
      'user_id': userId,
      'purchase_date': purchaseDate.toIso8601String(),
      'amount': amount,
      'payment_status': paymentStatus,
      'membership_name': membershipName,
    };
  }
}
