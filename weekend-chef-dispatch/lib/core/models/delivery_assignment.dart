import 'package:flutter/foundation.dart';

import 'proof_of_delivery.dart';
import 'geo_point.dart';

enum DeliveryStatus {
  readyForPickup,
  pickedUp,
  enRoute,
  delivered,
  completed,
}

extension DeliveryStatusX on DeliveryStatus {
  String get label {
    switch (this) {
      case DeliveryStatus.readyForPickup:
        return 'Ready for pickup';
      case DeliveryStatus.pickedUp:
        return 'Picked up';
      case DeliveryStatus.enRoute:
        return 'En route';
      case DeliveryStatus.delivered:
        return 'Delivered';
      case DeliveryStatus.completed:
        return 'Completed';
    }
  }

  DeliveryStatus advance() {
    switch (this) {
      case DeliveryStatus.readyForPickup:
        return DeliveryStatus.pickedUp;
      case DeliveryStatus.pickedUp:
        return DeliveryStatus.enRoute;
      case DeliveryStatus.enRoute:
        return DeliveryStatus.delivered;
      case DeliveryStatus.delivered:
        return DeliveryStatus.completed;
      case DeliveryStatus.completed:
        return DeliveryStatus.completed;
    }
  }
}

class DeliveryStop {
  const DeliveryStop({
    required this.label,
    required this.address,
    required this.coordinate,
    this.eta,
    this.isPickup = false,
  });

  final String label;
  final String address;
  final GeoPoint coordinate;
  final DateTime? eta;
  final bool isPickup;
}

class DeliveryRoute {
  const DeliveryRoute({
    required this.pickup,
    required this.dropoff,
    required this.distanceKm,
    required this.estimatedDuration,
    this.polyline = const [],
  });

  final DeliveryStop pickup;
  final DeliveryStop dropoff;
  final double distanceKm;
  final Duration estimatedDuration;
  final List<GeoPoint> polyline;
}

class AssignmentEvent {
  const AssignmentEvent({
    required this.timestamp,
    required this.message,
  });

  final DateTime timestamp;
  final String message;
}

class DeliveryAssignment {
  const DeliveryAssignment({
    required this.id,
    required this.orderNumber,
    required this.clientName,
    required this.cookName,
    required this.cuisine,
    required this.route,
    required this.status,
    required this.scheduledWindowStart,
    required this.scheduledWindowEnd,
    required this.maskedClientPhone,
    required this.maskedCookPhone,
    this.proofOfDelivery,
    this.events = const [],
    this.notes,
    this.rush = false,
  });

  final String id;
  final String orderNumber;
  final String clientName;
  final String cookName;
  final String cuisine;
  final DeliveryRoute route;
  final DeliveryStatus status;
  final DateTime scheduledWindowStart;
  final DateTime scheduledWindowEnd;
  final String maskedClientPhone;
  final String maskedCookPhone;
  final ProofOfDelivery? proofOfDelivery;
  final List<AssignmentEvent> events;
  final String? notes;
  final bool rush;

  bool get isCompleted => status == DeliveryStatus.completed;
  bool get hasProof => proofOfDelivery != null;

  DeliveryAssignment copyWith({
    DeliveryStatus? status,
    ProofOfDelivery? proofOfDelivery,
    List<AssignmentEvent>? events,
    String? notes,
    bool? rush,
  }) {
    return DeliveryAssignment(
      id: id,
      orderNumber: orderNumber,
      clientName: clientName,
      cookName: cookName,
      cuisine: cuisine,
      route: route,
      status: status ?? this.status,
      scheduledWindowStart: scheduledWindowStart,
      scheduledWindowEnd: scheduledWindowEnd,
      maskedClientPhone: maskedClientPhone,
      maskedCookPhone: maskedCookPhone,
      proofOfDelivery: proofOfDelivery ?? this.proofOfDelivery,
      events: events ?? this.events,
      notes: notes ?? this.notes,
      rush: rush ?? this.rush,
    );
  }

  DeliveryAssignment addEvent(AssignmentEvent event) {
    return copyWith(events: [...events, event]);
  }
}
