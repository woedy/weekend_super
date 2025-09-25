enum PayoutStatus { pending, released }

class Payout {
  const Payout({
    required this.id,
    required this.orderId,
    required this.description,
    required this.amount,
    required this.platformFee,
    required this.status,
    required this.expectedOn,
  });

  final String id;
  final String orderId;
  final String description;
  final double amount;
  final double platformFee;
  final PayoutStatus status;
  final DateTime expectedOn;

  Payout copyWith({
    String? id,
    String? orderId,
    String? description,
    double? amount,
    double? platformFee,
    PayoutStatus? status,
    DateTime? expectedOn,
  }) {
    return Payout(
      id: id ?? this.id,
      orderId: orderId ?? this.orderId,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      platformFee: platformFee ?? this.platformFee,
      status: status ?? this.status,
      expectedOn: expectedOn ?? this.expectedOn,
    );
  }
}

class EarningsBreakdown {
  const EarningsBreakdown({
    required this.pendingAdvances,
    required this.pendingFinals,
    required this.released,
    required this.platformFees,
  });

  final double pendingAdvances;
  final double pendingFinals;
  final double released;
  final double platformFees;

  double get projectedBalance => pendingAdvances + pendingFinals + released;
}
