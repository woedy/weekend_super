import 'package:flutter/material.dart';

import '../../../constants.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../localization/localization_extension.dart';
import '../domain/menu_item.dart';
import '../domain/menu_order_draft.dart';
import 'menu_builder_controller.dart';

class MenuBuilderScreen extends StatelessWidget {
  const MenuBuilderScreen({super.key, required this.controller, required this.onSchedule});

  final MenuBuilderController controller;
  final VoidCallback onSchedule;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final currencyFormatter = CurrencyFormatter();
    return Scaffold(
      appBar: AppBar(title: Text(l10n.translate('menuBuilderTitle'))),
      body: AnimatedBuilder(
        animation: controller,
        builder: (context, _) {
          final MenuOrderDraft draft = controller.draft;
          final MenuItem item = draft.item;
          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              if (item.photo.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Image.network(item.photo, fit: BoxFit.cover),
                ),
              const SizedBox(height: 16),
              Text(item.name, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              Text(item.description, style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 24),
              Text(l10n.translate('portionSize'), style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: item.portions
                    .map(
                      (portion) => ChoiceChip(
                        label: Text('${portion.label} · ${currencyFormatter.format(portion.price)}'),
                        selected: draft.selectedPortion?.id == portion.id,
                        onSelected: (_) => controller.selectPortion(portion),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 24),
              if (item.addons.isNotEmpty) ...[
                Text(l10n.translate('addons'), style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: item.addons
                      .map(
                        (addon) => FilterChip(
                          label: Text('${addon.label} · ${currencyFormatter.format(addon.price)}'),
                          selected: draft.selectedAddons.contains(addon),
                          onSelected: (_) => controller.toggleAddon(addon),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 24),
              ],
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(l10n.translate('quantity'), style: Theme.of(context).textTheme.titleMedium),
                  _QuantitySelector(
                    value: draft.quantity,
                    onDecrement: controller.decrementQuantity,
                    onIncrement: controller.incrementQuantity,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _PriceRow(label: l10n.translate('subtotal'), value: currencyFormatter.format(draft.subtotal)),
              _PriceRow(label: l10n.translate('groceryAdvance'), value: currencyFormatter.format(draft.groceryAdvance)),
              _PriceRow(label: l10n.translate('platformFee'), value: currencyFormatter.format(draft.platformFee)),
              const Divider(height: 32),
              _PriceRow(
                label: l10n.translate('totalDue'),
                value: currencyFormatter.format(draft.totalDueToday),
                highlight: true,
              ),
              _PriceRow(label: l10n.translate('remainingBalance'), value: currencyFormatter.format(draft.remainingBalance)),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: draft.selectedPortion == null ? null : onSchedule,
                child: Text(l10n.translate('scheduleDelivery')),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _QuantitySelector extends StatelessWidget {
  const _QuantitySelector({required this.value, required this.onDecrement, required this.onIncrement});

  final int value;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: value > 1 ? onDecrement : null,
          icon: const Icon(Icons.remove_circle_outline),
        ),
        Text('$value', style: Theme.of(context).textTheme.titleMedium),
        IconButton(
          onPressed: onIncrement,
          icon: const Icon(Icons.add_circle_outline),
        ),
      ],
    );
  }
}

class _PriceRow extends StatelessWidget {
  const _PriceRow({required this.label, required this.value, this.highlight = false});

  final String label;
  final String value;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: highlight ? theme.textTheme.titleMedium : theme.textTheme.bodyMedium),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: highlight ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
