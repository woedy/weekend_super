import 'package:flutter/material.dart';

import '../../constants.dart';
import '../../core/app_state.dart';
import '../../core/models/order.dart';
import '../../core/utils/date_formatters.dart';

class OrderDetailScreen extends StatefulWidget {
  const OrderDetailScreen({super.key, required this.orderId});

  final String orderId;

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  final TextEditingController _messageController = TextEditingController();

  static const List<String> _quickReplies = <String>[
    'Accepted — starting prep now.',
    'Running 10 minutes ahead of schedule.',
    'Ingredients secured. Receipt uploaded.',
    'Courier has pickup instructions.',
  ];

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = CookAppScope.of(context);
    final order = state.findOrder(widget.orderId);

    return Scaffold(
      appBar: AppBar(
        title: Text('Order ${order.id}'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(pagePadding),
        children: [
          _StatusCard(order: order),
          const SizedBox(height: 16),
          _LogisticsCard(order: order),
          const SizedBox(height: 16),
          _FinanceCard(order: order),
          const SizedBox(height: 16),
          if (order.instructions.isNotEmpty || order.dietaryNotes.isNotEmpty)
            _InstructionsCard(order: order),
          const SizedBox(height: 16),
          _ConversationCard(
            order: order,
            controller: _messageController,
          ),
        ],
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({required this.order});

  final CookOrder order;

  @override
  Widget build(BuildContext context) {
    final state = CookAppScope.of(context);
    final nextStages = order.stage.possibleNextStages;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Status', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: order.stage.color.withOpacity(0.14),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    order.stage.label,
                    style: TextStyle(
                      color: order.stage.color,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(formatDayAndTime(order.scheduledAt)),
              ],
            ),
            const SizedBox(height: 16),
            if (nextStages.isNotEmpty)
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final stage in nextStages)
                    FilledButton.tonal(
                      onPressed: () {
                        state.updateOrderStage(order.id, stage);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Order marked as ${stage.label.toLowerCase()}.')),
                        );
                      },
                      child: Text(stage == OrderStage.accepted
                          ? 'Accept order'
                          : 'Mark ${stage.label.toLowerCase()}'),
                    ),
                ],
              )
            else
              const Text('Order fully completed. Awaiting client rating or payout.'),
          ],
        ),
      ),
    );
  }
}

class _LogisticsCard extends StatelessWidget {
  const _LogisticsCard({required this.order});

  final CookOrder order;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Delivery & prep', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.schedule_outlined),
              title: const Text('Scheduled for'),
              subtitle: Text(formatDayAndTime(order.scheduledAt)),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.location_on_outlined),
              title: const Text('Deliver to'),
              subtitle: Text(order.deliveryAddress),
            ),
          ],
        ),
      ),
    );
  }
}

class _FinanceCard extends StatelessWidget {
  const _FinanceCard({required this.order});

  final CookOrder order;

  @override
  Widget build(BuildContext context) {
    final state = CookAppScope.of(context);
    final receiptUploaded = order.receiptUploaded;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Escrow & payouts', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _FinanceTile(
                    label: 'Grocery advance',
                    amount: order.groceryAdvance,
                    description: 'Released once you accept the order.',
                    icon: Icons.account_balance_wallet_outlined,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _FinanceTile(
                    label: 'Final payout',
                    amount: order.finalPayout,
                    description: 'Available after delivery confirmation.',
                    icon: Icons.payments_outlined,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(
                receiptUploaded ? Icons.receipt_long : Icons.receipt_long_outlined,
                color: receiptUploaded ? brandSuccess : brandTextSecondary,
              ),
              title: const Text('Grocery receipt'),
              subtitle: Text(
                receiptUploaded
                    ? 'Receipt uploaded — finance team has everything needed.'
                    : 'Upload a receipt to keep the grocery advance compliant.',
              ),
              trailing: TextButton(
                onPressed: () {
                  state.toggleReceipt(order.id, !receiptUploaded);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        receiptUploaded
                            ? 'Receipt marked as pending upload.'
                            : 'Receipt uploaded — thanks! ',
                      ),
                    ),
                  );
                },
                child: Text(receiptUploaded ? 'Replace' : 'Upload'),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Platform fee: ${formatCurrency(order.platformFee)} will be deducted before final payout.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: brandTextSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

class _FinanceTile extends StatelessWidget {
  const _FinanceTile({
    required this.label,
    required this.amount,
    required this.description,
    required this.icon,
  });

  final String label;
  final double amount;
  final String description;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: brandSurface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: brandTextSecondary),
          const SizedBox(height: 12),
          Text(
            formatCurrency(amount),
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 4),
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 8),
          Text(
            description,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: brandTextSecondary),
          ),
        ],
      ),
    );
  }
}

class _InstructionsCard extends StatelessWidget {
  const _InstructionsCard({required this.order});

  final CookOrder order;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Client notes', style: Theme.of(context).textTheme.titleLarge),
            if (order.instructions.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(order.instructions),
            ],
            if (order.dietaryNotes.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (final note in order.dietaryNotes)
                    Chip(
                      label: Text(note),
                      backgroundColor: brandWarning.withOpacity(0.14),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ConversationCard extends StatefulWidget {
  const _ConversationCard({
    required this.order,
    required this.controller,
  });

  final CookOrder order;
  final TextEditingController controller;

  @override
  State<_ConversationCard> createState() => _ConversationCardState();
}

class _ConversationCardState extends State<_ConversationCard> {
  @override
  Widget build(BuildContext context) {
    final state = CookAppScope.of(context);
    final order = state.findOrder(widget.order.id);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Chat with client & dispatch', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            ...order.conversation.map(
              (message) => _MessageBubble(message: message),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final reply in _OrderDetailScreenState._quickReplies)
                  OutlinedButton(
                    onPressed: () => _sendMessage(context, reply),
                    child: Text(reply),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: widget.controller,
                    decoration: const InputDecoration(
                      hintText: 'Send an update to the client or dispatcher',
                    ),
                    minLines: 1,
                    maxLines: 3,
                  ),
                ),
                const SizedBox(width: 12),
                FilledButton(
                  onPressed: () => _sendMessage(context, widget.controller.text.trim()),
                  child: const Icon(Icons.send),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _sendMessage(BuildContext context, String text) {
    if (text.isEmpty) return;
    final state = CookAppScope.of(context);
    final message = OrderMessage(
      author: 'You',
      body: text,
      timestamp: DateTime.now(),
      role: 'Cook',
    );
    state.addOrderMessage(widget.order.id, message);
    widget.controller.clear();
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message});

  final OrderMessage message;

  @override
  Widget build(BuildContext context) {
    final isCook = message.role.toLowerCase() == 'cook' || message.author == 'You';
    final alignment = isCook ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final color = isCook ? brandPrimary.withOpacity(0.15) : brandSurface;
    final labelColor = isCook ? brandPrimary : brandTextSecondary;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: alignment,
        children: [
          Text(
            '${message.author} • ${formatDayAndTime(message.timestamp)}',
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: labelColor, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Container(
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(14),
            ),
            padding: const EdgeInsets.all(12),
            child: Text(message.body),
          ),
        ],
      ),
    );
  }
}
