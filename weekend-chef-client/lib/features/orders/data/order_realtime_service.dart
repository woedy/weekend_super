import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';

import '../../../constants.dart';
import '../domain/order_models.dart';

class OrderRealtimeService {
  OrderRealtimeService({PusherChannelsFlutter? client}) : _client = client ?? PusherChannelsFlutter.getInstance();

  final PusherChannelsFlutter _client;
  final StreamController<OrderStatusUpdate> _controller = StreamController.broadcast();
  bool _connected = false;

  Stream<OrderStatusUpdate> get stream => _controller.stream;

  Future<void> connect(String orderRoom) async {
    if (EnvironmentConfig.pusherKey.isEmpty) {
      _simulate(orderRoom);
      return;
    }
    if (!_connected) {
      await _client.init(
        apiKey: EnvironmentConfig.pusherKey,
        cluster: EnvironmentConfig.pusherCluster,
        onConnectionStateChange: (state) {
          debugPrint('Pusher connection: $state');
        },
        onError: (message, code, exception) {
          debugPrint('Pusher error: $message');
        },
      );
      await _client.connect();
      _connected = true;
    }
    await _client.subscribe(
      channelName: 'private-order-$orderRoom',
      onEvent: (event) {
        final data = event.data as Map<dynamic, dynamic>?;
        if (data == null) return;
        final mapped = data.map((key, value) => MapEntry(key.toString(), value));
        final update = OrderStatusUpdate.fromJson(mapped);
        _controller.add(update);
      },
    );
  }

  Future<void> disconnect(String orderRoom) async {
    if (EnvironmentConfig.pusherKey.isEmpty) {
      return;
    }
    await _client.unsubscribe(channelName: 'private-order-$orderRoom');
  }

  void _simulate(String orderRoom) {
    var step = 0;
    const statuses = [
      'accepted',
      'cooking',
      'ready',
      'dispatched',
      'delivered',
    ];
    Timer.periodic(const Duration(seconds: 15), (timer) {
      if (step >= statuses.length) {
        timer.cancel();
        return;
      }
      _controller.add(
        OrderStatusUpdate(status: statuses[step], changedAt: DateTime.now()),
      );
      step += 1;
    });
  }
}
