import 'package:flutter/material.dart';

import '../../constants.dart';
import '../../core/app_state.dart';
import '../../core/models/order.dart';
import '../../core/models/payout.dart';
import '../../core/utils/date_formatters.dart';

class EarningsScreen extends StatelessWidget {
  const EarningsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = CookAppScope.of(context);
    final breakdown = state.earningsBreakdown;
    final payouts = List<Payout>.from(state.payouts)
      ..sort((a, b) => b.expectedOn.compareTo(a.expectedOn));
    final activeOrders = state.orders.where((order) => order.isActive).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Earnings dashboard'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(pagePadding),
        children: [
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              _SummaryCard(
                title: 'Pending advances',
                amount: breakdown.pendingAdvances,
                description: 'Released as soon as you accept upcoming orders.',
                icon: Icons.account_balance_wallet_outlined,
                color: brandPrimary,
              ),
              _SummaryCard(
                title: 'Pending final payouts',
                amount: breakdown.pendingFinals,
                description: 'Arrives once delivery proof is approved.',
                icon: Icons.payments_outlined,
                color: brandWarning,
              ),
              _SummaryCard(
                title: 'Released to date',
                amount: breakdown.released,
                description: 'Total deposited to your connected account.',
                icon: Icons.savings_outlined,
                color: brandSuccess,
              ),
            ],
          ),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Upcoming order obligations', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 12),
                  if (activeOrders.isEmpty)
                    const Text('No active orders at the moment.')
                  else
                    Column(
                      children: [
                        for (final order in activeOrders)
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: const Icon(Icons.event_note_outlined),
                            title: Text(order.menuSummary),
                            subtitle: Text('Deliver by ${formatDayAndTime(order.scheduledAt)}'),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text('Advance ${formatCurrency(order.groceryAdvance)}'),
                                Text('Final ${formatCurrency(order.finalPayout)}',
                                    style: Theme.of(context).textTheme.bodySmall),
                              ],
                            ),
                          ),
                      ],
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text('Payout ledger', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          if (payouts.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text('No payouts scheduled yet.'),
              ),
            )
          else
            Column(
              children: [
                for (final payout in payouts)
                  Card(
                    child: ListTile(
                      leading: Icon(
                        payout.status == PayoutStatus.released
                            ? Icons.check_circle
                            : Icons.schedule_outlined,
                        color: payout.status == PayoutStatus.released
                            ? brandSuccess
                            : brandWarning,
                      ),
                      title: Text(payout.description),
                      subtitle: Text('Expected ${formatPayoutStatus(payout.expectedOn)} • Platform fee ${formatCurrency(payout.platformFee)}'),
                      trailing: Text(
                        formatCurrency(payout.amount),
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
              ],
            ),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('How payouts work', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 12),
                  const Text(
                    '1. Accept the order to unlock the grocery advance within minutes.\n'
                    '2. Upload your grocery receipt before marking the order ready to keep compliance tight.\n'
                    '3. Once delivery proof is submitted, we release the remaining balance minus the platform fee.',
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Total platform fees collected so far: ${formatCurrency(breakdown.platformFees)}. Keep receipts up to date to avoid payout delays.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: brandTextSecondary),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.title,
    required this.amount,
    required this.description,
    required this.icon,
    required this.color,
  });

  final String title;
  final double amount;
  final String description;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 240,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 16),
          Text(
            formatCurrency(amount),
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
          ),
          const SizedBox(height: 6),
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 6),
          Text(
            description,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: color.withOpacity(0.7)),
          ),
        ],
      ),
    );
  }
}
