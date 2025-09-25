import 'package:flutter/material.dart';

import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_time_extensions.dart';
import '../../../localization/app_localizations.dart';
import '../../../localization/localization_extension.dart';
import '../../menu/domain/menu_item.dart';
import '../domain/chef_summary.dart';
import 'discovery_controller.dart';

class DiscoveryScreen extends StatefulWidget {
  const DiscoveryScreen({super.key, required this.controller, required this.onMenuSelected});

  final DiscoveryController controller;
  final void Function(ChefSummary chef, MenuItem item) onMenuSelected;

  @override
  State<DiscoveryScreen> createState() => _DiscoveryScreenState();
}

class _DiscoveryScreenState extends State<DiscoveryScreen> {
  final CurrencyFormatter _currencyFormatter = CurrencyFormatter();
  final DateTimeFormatter _dateFormatter = const DateTimeFormatter();

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
        final controller = widget.controller;
        return RefreshIndicator(
          onRefresh: controller.load,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 120),
            children: [
              if (controller.offlineFallback)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Material(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(16),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(l10n.translate('offlineFallback')),
                    ),
                  ),
                ),
              Text(
                l10n.translate('discoverTitle'),
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              _FilterSection(
                title: l10n.translate('filterCuisine'),
                options: controller.cuisines,
                selected: controller.selectedCuisine,
                onSelected: controller.selectCuisine,
              ),
              _FilterSection(
                title: l10n.translate('filterDiet'),
                options: controller.diets,
                selected: controller.selectedDiet,
                onSelected: controller.selectDiet,
              ),
              _FilterSection(
                title: l10n.translate('filterLocation'),
                options: controller.locations,
                selected: controller.selectedLocation,
                onSelected: controller.selectLocation,
              ),
              if (controller.selectedCuisine != null || controller.selectedDiet != null || controller.selectedLocation != null)
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: controller.clearFilters,
                    child: Text(l10n.translate('clearFilters')),
                  ),
                ),
              const SizedBox(height: 8),
              if (controller.isLoading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 48),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (controller.chefs.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 48),
                  child: Center(child: Text(l10n.translate('emptyOrders'))),
                )
              else
                ...controller.chefs.map(
                  (chef) => Padding(
                    padding: const EdgeInsets.only(bottom: 24),
                    child: _ChefCard(
                      chef: chef,
                      currencyFormatter: _currencyFormatter,
                      dateFormatter: _dateFormatter,
                      onMenuSelected: widget.onMenuSelected,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _FilterSection extends StatelessWidget {
  const _FilterSection({
    required this.title,
    required this.options,
    required this.selected,
    required this.onSelected,
  });

  final String title;
  final Iterable<String> options;
  final String? selected;
  final void Function(String?) onSelected;

  @override
  Widget build(BuildContext context) {
    if (options.isEmpty) {
      return const SizedBox.shrink();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: options
              .map(
                (option) => ChoiceChip(
                  label: Text(option),
                  selected: selected == option,
                  onSelected: (_) => onSelected(option),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

class _ChefCard extends StatelessWidget {
  const _ChefCard({
    required this.chef,
    required this.currencyFormatter,
    required this.dateFormatter,
    required this.onMenuSelected,
  });

  final ChefSummary chef;
  final CurrencyFormatter currencyFormatter;
  final DateTimeFormatter dateFormatter;
  final void Function(ChefSummary chef, MenuItem item) onMenuSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final nextAvailable = dateFormatter.formatDay(chef.nextAvailable);
    final ratingText = '${chef.averageRating.toStringAsFixed(1)} · ${chef.cuisines.join(', ')}';
    return Material(
      elevation: 0,
      borderRadius: BorderRadius.circular(24),
      color: Colors.white,
      child: InkWell(
        onTap: chef.menuItems.isNotEmpty ? () => onMenuSelected(chef, chef.menuItems.first) : null,
        borderRadius: BorderRadius.circular(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: chef.heroImage.isNotEmpty
                    ? Image.network(
                        chef.heroImage,
                        fit: BoxFit.cover,
                      )
                    : Container(color: Colors.grey.shade200),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    chef.displayName,
                    style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 4),
                  Text(chef.tagline, style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey.shade700)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 18),
                      const SizedBox(width: 4),
                      Text(ratingText, style: theme.textTheme.bodyMedium),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text('${chef.locationName} · ${currencyFormatter.format(chef.startingFrom)}'),
                  const SizedBox(height: 8),
                  Text(
                    '${l10n.translate('availabilityLabel')}: $nextAvailable',
                    style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 16),
                  if (chef.menuItems.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l10n.translate('recommendedSection'), style: theme.textTheme.titleMedium),
                        const SizedBox(height: 8),
                        ...chef.menuItems.take(2).map(
                          (item) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: _MenuPreviewCard(
                              item: item,
                              currencyFormatter: currencyFormatter,
                              onTap: () => onMenuSelected(chef, item),
                            ),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuPreviewCard extends StatelessWidget {
  const _MenuPreviewCard({required this.item, required this.currencyFormatter, required this.onTap});

  final MenuItem item;
  final CurrencyFormatter currencyFormatter;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: Colors.grey.shade50,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: item.photo.isNotEmpty
                    ? Image.network(item.photo, width: 72, height: 72, fit: BoxFit.cover)
                    : Container(width: 72, height: 72, color: Colors.grey.shade200),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.name, style: theme.textTheme.titleMedium),
                    const SizedBox(height: 4),
                    Text(
                      item.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey.shade700),
                    ),
                    const SizedBox(height: 6),
                    Text(currencyFormatter.format(item.minimumPrice), style: theme.textTheme.bodyMedium),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
