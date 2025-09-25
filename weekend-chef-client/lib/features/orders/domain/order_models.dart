class OrderStatusUpdate {
  OrderStatusUpdate({
    required this.status,
    required this.changedAt,
    this.notes,
  });

  final String status;
  final DateTime changedAt;
  final String? notes;

  factory OrderStatusUpdate.fromJson(Map<String, dynamic> json) {
    return OrderStatusUpdate(
      status: json['status']?.toString() ?? 'pending',
      changedAt: DateTime.tryParse(json['changedAt']?.toString() ?? '') ?? DateTime.now(),
      notes: json['notes']?.toString(),
    );
  }
}

class OrderSummary {
  OrderSummary({
    required this.orderId,
    required this.chefId,
    required this.menuItemId,
    required this.status,
    required this.total,
    required this.groceryAdvance,
    required this.remainingBalance,
    required this.timeline,
  });

  final String orderId;
  final String chefId;
  final String menuItemId;
  final String status;
  final double total;
  final double groceryAdvance;
  final double remainingBalance;
  final List<OrderStatusUpdate> timeline;

  factory OrderSummary.fromJson(Map<String, dynamic> json) {
    final List<dynamic> timeline = json['timeline'] as List<dynamic>? ?? const [];
    return OrderSummary(
      orderId: json['orderId']?.toString() ?? '',
      chefId: json['chefId']?.toString() ?? '',
      menuItemId: json['menuItemId']?.toString() ?? '',
      status: json['status']?.toString() ?? 'pending',
      total: (json['total'] as num?)?.toDouble() ?? 0,
      groceryAdvance: (json['groceryAdvance'] as num?)?.toDouble() ?? 0,
      remainingBalance: (json['remainingBalance'] as num?)?.toDouble() ?? 0,
      timeline: timeline
          .map((entry) => OrderStatusUpdate.fromJson(entry as Map<String, dynamic>))
          .toList(),
    );
  }
}
