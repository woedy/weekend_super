import 'package:flutter/material.dart';

import '../../../constants.dart';
import '../../../core/payment/payment_service.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_time_extensions.dart';
import '../../../localization/localization_extension.dart';
import '../../authentication/domain/user_profile.dart';
import 'menu_builder_controller.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({
    super.key,
    required this.controller,
    required this.paymentService,
    required this.user,
    required this.onComplete,
  });

  final MenuBuilderController controller;
  final PaymentService paymentService;
  final UserProfile user;
  final VoidCallback onComplete;

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  bool _processing = false;
  String? _error;
  final CurrencyFormatter _currencyFormatter = CurrencyFormatter();
  final DateTimeFormatter _dateFormatter = const DateTimeFormatter();

  Future<void> _handleCheckout() async {
    setState(() {
      _processing = true;
      _error = null;
    });
    final draft = widget.controller.draft;
    final success = await widget.paymentService.processPayment(
      email: widget.user.email,
      amount: draft.totalDueToday,
    );
    if (!mounted) return;
    if (success) {
      widget.onComplete();
    } else {
      setState(() {
        _processing = false;
        _error = 'Payment failed. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final draft = widget.controller.draft;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.translate('checkoutTitle'))),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(l10n.translate('orderSummary'), style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          _SummaryRow(label: l10n.translate('orderDish'), value: draft.item.name),
          if (draft.selectedPortion != null)
            _SummaryRow(label: l10n.translate('orderPortion'), value: draft.selectedPortion!.label),
          if (draft.selectedAddons.isNotEmpty)
            _SummaryRow(
              label: l10n.translate('orderAddons'),
              value: draft.selectedAddons.map((addon) => addon.label).join(', '),
            ),
          _SummaryRow(label: l10n.translate('quantity'), value: draft.quantity.toString()),
          if (draft.deliveryDate != null && draft.deliveryTime != null)
            _SummaryRow(
              label: l10n.translate('scheduleDelivery'),
              value:
                  '${_dateFormatter.formatDay(draft.deliveryDate!)} · ${_dateFormatter.formatTime(DateTime(draft.deliveryDate!.year, draft.deliveryDate!.month, draft.deliveryDate!.day, draft.deliveryTime!.hour, draft.deliveryTime!.minute))}',
            ),
          const Divider(height: 32),
          _SummaryRow(label: l10n.translate('subtotal'), value: _currencyFormatter.format(draft.subtotal)),
          _SummaryRow(label: l10n.translate('groceryAdvance'), value: _currencyFormatter.format(draft.groceryAdvance)),
          _SummaryRow(label: l10n.translate('platformFee'), value: _currencyFormatter.format(draft.platformFee)),
          _SummaryRow(label: l10n.translate('totalDue'), value: _currencyFormatter.format(draft.totalDueToday), highlight: true),
          _SummaryRow(label: l10n.translate('remainingBalance'), value: _currencyFormatter.format(draft.remainingBalance)),
          const SizedBox(height: 24),
          Text(l10n.translate('paymentMethod'), style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 0),
            leading: const Icon(Icons.credit_card),
            title: Text(l10n.translate('paystackOption')),
            subtitle: Text(widget.user.email),
            trailing: const Icon(Icons.check_circle, color: AppColors.primary),
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(_error!, style: const TextStyle(color: AppColors.error)),
          ],
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _processing ? null : _handleCheckout,
            child: _processing
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation(AppColors.onPrimary)),
                      ),
                      const SizedBox(width: 12),
                      Text(l10n.translate('processingPayment')),
                    ],
                  )
                : Text(l10n.translate('placeOrder')),
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.label, required this.value, this.highlight = false});

  final String label;
  final String value;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final style = highlight
        ? Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)
        : Theme.of(context).textTheme.bodyMedium;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: style),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: style,
            ),
          ),
        ],
      ),
    );
  }
}
