import 'dart:math';

import 'package:flutter/material.dart';

import '../../../core/models/geo_point.dart';

class RoutePreviewMap extends StatelessWidget {
  const RoutePreviewMap({
    super.key,
    required this.polyline,
    required this.pickup,
    required this.dropoff,
    this.height = 160,
  });

  final List<GeoPoint> polyline;
  final GeoPoint pickup;
  final GeoPoint dropoff;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: CustomPaint(
          painter: _RoutePainter(
            points: [pickup, ...polyline, dropoff],
            pickup: pickup,
            dropoff: dropoff,
            colorScheme: Theme.of(context).colorScheme,
          ),
        ),
      ),
    );
  }
}

class _RoutePainter extends CustomPainter {
  _RoutePainter({
    required this.points,
    required this.pickup,
    required this.dropoff,
    required this.colorScheme,
  });

  final List<GeoPoint> points;
  final GeoPoint pickup;
  final GeoPoint dropoff;
  final ColorScheme colorScheme;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = LinearGradient(
        colors: [
          colorScheme.surfaceVariant,
          colorScheme.surface,
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);

    if (points.isEmpty) {
      return;
    }

    final latitudes = points.map((p) => p.latitude);
    final longitudes = points.map((p) => p.longitude);
    final minLat = latitudes.reduce(min);
    final maxLat = latitudes.reduce(max);
    final minLon = longitudes.reduce(min);
    final maxLon = longitudes.reduce(max);

    double scaleLat(double lat) =>
        size.height - ((lat - minLat) / max(0.0001, (maxLat - minLat)) * size.height);
    double scaleLon(double lon) =>
        ((lon - minLon) / max(0.0001, (maxLon - minLon)) * size.width);

    final routePaint = Paint()
      ..color = colorScheme.primary
      ..strokeWidth = 6
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final routePath = Path();
    for (var i = 0; i < points.length; i++) {
      final point = points[i];
      final offset = Offset(scaleLon(point.longitude), scaleLat(point.latitude));
      if (i == 0) {
        routePath.moveTo(offset.dx, offset.dy);
      } else {
        routePath.lineTo(offset.dx, offset.dy);
      }
    }
    canvas.drawShadow(routePath, Colors.black45, 4, false);
    canvas.drawPath(routePath, routePaint);

    final pickupOffset = Offset(scaleLon(pickup.longitude), scaleLat(pickup.latitude));
    final dropoffOffset = Offset(scaleLon(dropoff.longitude), scaleLat(dropoff.latitude));

    final pickupPaint = Paint()..color = colorScheme.tertiary;
    final dropoffPaint = Paint()..color = colorScheme.primary;

    canvas.drawCircle(pickupOffset, 10, Paint()..color = Colors.white);
    canvas.drawCircle(pickupOffset, 8, pickupPaint);
    canvas.drawCircle(dropoffOffset, 10, Paint()..color = Colors.white);
    canvas.drawCircle(dropoffOffset, 8, dropoffPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
