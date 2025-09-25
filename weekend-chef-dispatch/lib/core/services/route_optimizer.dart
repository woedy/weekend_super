import 'dart:math';

import '../models/delivery_assignment.dart';
import '../models/geo_point.dart';

class RouteOptimizer {
  const RouteOptimizer();

  DeliveryRoute optimize(DeliveryRoute route) {
    if (route.polyline.isNotEmpty) {
      return route;
    }
    final meters = _haversine(route.pickup.coordinate, route.dropoff.coordinate);
    final estimatedMinutes = max(8, (meters / 1000 * 3).round());
    return DeliveryRoute(
      pickup: route.pickup,
      dropoff: route.dropoff,
      distanceKm: meters / 1000,
      estimatedDuration: Duration(minutes: estimatedMinutes),
      polyline: [route.pickup.coordinate, route.dropoff.coordinate],
    );
  }

  double _haversine(GeoPoint start, GeoPoint end) {
    const earthRadius = 6371000; // meters
    final dLat = _degToRad(end.latitude - start.latitude);
    final dLon = _degToRad(end.longitude - start.longitude);
    final lat1 = _degToRad(start.latitude);
    final lat2 = _degToRad(end.latitude);

    final a = sin(dLat / 2) * sin(dLat / 2) +
        sin(dLon / 2) * sin(dLon / 2) * cos(lat1) * cos(lat2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c;
  }

  double _degToRad(double degree) => degree * pi / 180;
}
