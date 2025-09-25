import 'package:flutter/material.dart';

import '../../constants.dart';
import '../../core/app_state.dart';
import '../../core/models/order.dart';
import '../../core/utils/date_formatters.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key, required this.onViewOrder});

  final ValueChanged<CookOrder> onViewOrder;

  @override
  Widget build(BuildContext context) {
    final state = CookAppScope.of(context);
    final orders = List<CookOrder>.from(state.orders)
      ..sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));
    final activeOrders = orders.where((order) => order.stage != OrderStage.completed).toList();
    final completedOrders = orders.where((order) => order.stage == OrderStage.completed).toList();

    final awaitingAcceptance = activeOrders.where((order) => order.stage == OrderStage.pending).length;
    final inProduction = activeOrders.where((order) => order.stage == OrderStage.accepted || order.stage == OrderStage.cooking).length;
    final readyForDispatch = activeOrders.where((order) => order.stage == OrderStage.ready).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Order pipeline'),
        actions: [
          if (awaitingAcceptance > 0)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: brandPrimary.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    '$awaitingAcceptance awaiting acceptance',
                    style: const TextStyle(color: brandPrimary, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(pagePadding),
        children: [
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              _SummaryChip(
                label: 'In prep',
                value: inProduction.toString(),
                icon: Icons.kitchen,
                background: brandPrimary.withOpacity(0.12),
                foreground: brandPrimary,
              ),
              _SummaryChip(
                label: 'Ready for dispatch',
                value: readyForDispatch.toString(),
                icon: Icons.delivery_dining,
                background: brandSuccess.withOpacity(0.14),
                foreground: brandSuccess,
              ),
              _SummaryChip(
                label: 'Completed this week',
                value: completedOrders.length.toString(),
                icon: Icons.emoji_events_outlined,
                background: brandTextSecondary.withOpacity(0.14),
                foreground: brandTextSecondary,
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text('Active orders', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          if (activeOrders.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text('No active orders right now. We will notify you when clients submit new requests.'),
              ),
            )
          else
            Column(
              children: [
                for (final order in activeOrders)
                  _OrderCard(
                    order: order,
                    onTap: () => onViewOrder(order),
                  ),
              ],
            ),
          const SizedBox(height: 32),
          Text('Recently delivered', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          if (completedOrders.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text('Delivered orders will appear here once clients confirm delivery and ratings are submitted.'),
              ),
            )
          else
            Column(
              children: [
                for (final order in completedOrders)
                  _OrderCard(
                    order: order,
                    onTap: () => onViewOrder(order),
                    subtle: true,
                  ),
              ],
            ),
        ],
      ),
    );
  }
}

class _SummaryChip extends StatelessWidget {
  const _SummaryChip({
    required this.label,
    required this.value,
    required this.icon,
    required this.background,
    required this.foreground,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: foreground),
          const SizedBox(height: 12),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: foreground,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: foreground.withOpacity(0.7)),
          ),
        ],
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({
    required this.order,
    required this.onTap,
    this.subtle = false,
  });

  final CookOrder order;
  final VoidCallback onTap;
  final bool subtle;

  @override
  Widget build(BuildContext context) {
    final statusColor = order.stage.color;
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(order.clientName,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                )),
                        const SizedBox(height: 4),
                        Text(order.menuSummary, style: Theme.of(context).textTheme.bodyMedium),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      order.stage.label,
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.schedule, size: 18, color: brandTextSecondary),
                  const SizedBox(width: 6),
                  Text(formatDayAndTime(order.scheduledAt)),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.location_on_outlined, size: 18, color: brandTextSecondary),
                  const SizedBox(width: 6),
                  Expanded(child: Text(order.deliveryAddress)),
                ],
              ),
              if (order.dietaryNotes.isNotEmpty) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    for (final note in order.dietaryNotes)
                      Chip(
                        label: Text(note),
                        backgroundColor: subtle
                            ? brandSurface
                            : brandWarning.withOpacity(0.14),
                      ),
                  ],
                ),
              ],
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.account_balance_wallet_outlined,
                      size: 18, color: brandTextSecondary),
                  const SizedBox(width: 6),
                  Text('Advance ${formatCurrency(order.groceryAdvance)}'),
                  const SizedBox(width: 12),
                  const Icon(Icons.payments_outlined, size: 18, color: brandTextSecondary),
                  const SizedBox(width: 6),
                  Text('Final ${formatCurrency(order.finalPayout)}'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
