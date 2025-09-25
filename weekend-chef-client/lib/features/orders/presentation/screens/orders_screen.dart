import 'package:flutter/material.dart';

import '../../../../localization/app_localizations.dart';
import '../../../../localization/localization_extension.dart';
import '../../../discovery/presentation/discovery_controller.dart';
import '../../../menu/domain/menu_item.dart';
import '../../domain/order_models.dart';
import '../orders_controller.dart';
import 'order_detail_screen.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key, required this.controller, required this.discoveryController});

  final OrdersController controller;
  final DiscoveryController discoveryController;

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  @override
  void initState() {
    super.initState();
    widget.controller.load();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) {
        final orders = widget.controller.orders;
        return RefreshIndicator(
          onRefresh: widget.controller.load,
          child: ListView.separated(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(24),
            itemBuilder: (context, index) {
              if (widget.controller.isLoading && orders.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }
              final order = orders[index];
              final MenuItem? menuItem = widget.discoveryController.findMenuItem(order.chefId, order.menuItemId);
              return ListTile(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                tileColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                title: Text(menuItem?.name ?? 'Order ${order.orderId}'),
                subtitle: Text('${l10n.translate('statusTimeline')}: ${_statusLabel(l10n, order.status)}'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => OrderDetailScreen(
                        controller: widget.controller,
                        orderId: order.orderId,
                        discoveryController: widget.discoveryController,
                      ),
                    ),
                  );
                },
              );
            },
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemCount: widget.controller.isLoading && orders.isEmpty ? 1 : orders.length,
          ),
        );
      },
    );
  }

  String _statusLabel(AppLocalizations l10n, String status) {
    switch (status) {
      case 'pending':
        return l10n.translate('statusPending');
      case 'accepted':
        return l10n.translate('statusAccepted');
      case 'cooking':
        return l10n.translate('statusCooking');
      case 'ready':
        return l10n.translate('statusReady');
      case 'dispatched':
        return l10n.translate('statusDispatched');
      case 'delivered':
        return l10n.translate('statusDelivered');
      case 'completed':
        return l10n.translate('statusCompleted');
      default:
        return status;
    }
  }
}
