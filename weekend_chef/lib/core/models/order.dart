import 'package:flutter/material.dart';

import '../../constants.dart';

enum OrderStage {
  pending,
  accepted,
  cooking,
  ready,
  dispatched,
  delivered,
  completed,
}

extension OrderStageDisplay on OrderStage {
  String get label {
    switch (this) {
      case OrderStage.pending:
        return 'Pending acceptance';
      case OrderStage.accepted:
        return 'Accepted';
      case OrderStage.cooking:
        return 'Cooking';
      case OrderStage.ready:
        return 'Ready for pickup';
      case OrderStage.dispatched:
        return 'Out for delivery';
      case OrderStage.delivered:
        return 'Delivered';
      case OrderStage.completed:
        return 'Completed';
    }
  }

  Color get color {
    switch (this) {
      case OrderStage.pending:
        return brandWarning;
      case OrderStage.accepted:
      case OrderStage.cooking:
        return brandPrimary;
      case OrderStage.ready:
        return brandSuccess;
      case OrderStage.dispatched:
      case OrderStage.delivered:
      case OrderStage.completed:
        return brandTextSecondary;
    }
  }

  List<OrderStage> get possibleNextStages {
    switch (this) {
      case OrderStage.pending:
        return const [OrderStage.accepted];
      case OrderStage.accepted:
        return const [OrderStage.cooking, OrderStage.ready];
      case OrderStage.cooking:
        return const [OrderStage.ready];
      case OrderStage.ready:
        return const [OrderStage.dispatched];
      case OrderStage.dispatched:
        return const [OrderStage.delivered];
      case OrderStage.delivered:
        return const [OrderStage.completed];
      case OrderStage.completed:
        return const [];
    }
  }
}

class OrderMessage {
  const OrderMessage({
    required this.author,
    required this.body,
    required this.timestamp,
    required this.role,
  });

  final String author;
  final String body;
  final DateTime timestamp;
  final String role;
}

class CookOrder {
  const CookOrder({
    required this.id,
    required this.clientName,
    required this.menuSummary,
    required this.scheduledAt,
    required this.deliveryAddress,
    required this.instructions,
    required this.dietaryNotes,
    required this.stage,
    required this.groceryAdvance,
    required this.finalPayout,
    required this.platformFee,
    required this.conversation,
    this.receiptUploaded = false,
  });

  final String id;
  final String clientName;
  final String menuSummary;
  final DateTime scheduledAt;
  final String deliveryAddress;
  final String instructions;
  final List<String> dietaryNotes;
  final OrderStage stage;
  final double groceryAdvance;
  final double finalPayout;
  final double platformFee;
  final List<OrderMessage> conversation;
  final bool receiptUploaded;

  CookOrder copyWith({
    String? id,
    String? clientName,
    String? menuSummary,
    DateTime? scheduledAt,
    String? deliveryAddress,
    String? instructions,
    List<String>? dietaryNotes,
    OrderStage? stage,
    double? groceryAdvance,
    double? finalPayout,
    double? platformFee,
    List<OrderMessage>? conversation,
    bool? receiptUploaded,
  }) {
    return CookOrder(
      id: id ?? this.id,
      clientName: clientName ?? this.clientName,
      menuSummary: menuSummary ?? this.menuSummary,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      instructions: instructions ?? this.instructions,
      dietaryNotes: dietaryNotes ?? List<String>.from(this.dietaryNotes),
      stage: stage ?? this.stage,
      groceryAdvance: groceryAdvance ?? this.groceryAdvance,
      finalPayout: finalPayout ?? this.finalPayout,
      platformFee: platformFee ?? this.platformFee,
      conversation: conversation ?? List<OrderMessage>.from(this.conversation),
      receiptUploaded: receiptUploaded ?? this.receiptUploaded,
    );
  }

  bool get isActive => stage != OrderStage.completed;
}
