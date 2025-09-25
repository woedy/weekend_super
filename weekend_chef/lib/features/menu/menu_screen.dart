import 'package:flutter/material.dart';

import '../../constants.dart';
import '../../core/app_state.dart';
import '../../core/models/dish.dart';

class MenuScreen extends StatelessWidget {
  const MenuScreen({
    super.key,
    required this.onCreateDish,
    required this.onUpdateDish,
    required this.onDeleteDish,
  });

  final ValueChanged<Dish> onCreateDish;
  final ValueChanged<Dish> onUpdateDish;
  final ValueChanged<String> onDeleteDish;

  @override
  Widget build(BuildContext context) {
    final state = CookAppScope.of(context);
    final dishes = List<Dish>.from(state.dishes)
      ..sort((a, b) => a.name.compareTo(b.name));
    final lowStockCount = dishes.where((dish) => dish.isLowStock).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Menu & inventory'),
        actions: [
          IconButton(
            onPressed: () => _openDishSheet(context),
            icon: const Icon(Icons.add_circle_outline),
            tooltip: 'Add dish',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(pagePadding),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(Icons.inventory_2_outlined, size: 32, color: brandWarning),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      lowStockCount > 0
                          ? '$lowStockCount menu items are low on inventory. Restock soon to avoid missing orders.'
                          : 'Inventory looks healthy. Keep an eye on grocery costs to maintain margins.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          for (final dish in dishes)
            _DishCard(
              dish: dish,
              onEdit: () => _openDishSheet(context, dish: dish),
              onDelete: () => onDeleteDish(dish.id),
              onTogglePublished: (value) => onUpdateDish(dish.copyWith(isPublished: value)),
            ),
          const SizedBox(height: 16),
          Text(
            'Pricing guidance is generated from your reorder rate. Items with higher reorder rates can sustainably handle a slightly higher price.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: brandTextSecondary),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openDishSheet(context),
        icon: const Icon(Icons.add),
        label: const Text('New dish'),
      ),
    );
  }

  Future<void> _openDishSheet(BuildContext context, {Dish? dish}) async {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: dish?.name ?? '');
    final descriptionController = TextEditingController(text: dish?.description ?? '');
    final priceController = TextEditingController(
      text: dish != null ? dish.price.toStringAsFixed(2) : '',
    );
    final leadTimeController = TextEditingController(
      text: dish != null ? dish.leadTimeMinutes.toString() : '90',
    );
    final inventoryController = TextEditingController(
      text: dish != null ? dish.inventory.toString() : '10',
    );
    final lowStockController = TextEditingController(
      text: dish != null ? dish.lowStockThreshold.toString() : '3',
    );
    final ingredientsController = TextEditingController(
      text: dish != null ? dish.ingredients.join(', ') : '',
    );
    double reorderRate = dish?.reorderRate ?? 0.5;
    bool isPublished = dish?.isPublished ?? true;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
            left: 24,
            right: 24,
            top: 24,
          ),
          child: StatefulBuilder(
            builder: (context, setModalState) {
              final basePrice = double.tryParse(priceController.text) ?? 0;
              final suggested = _suggestPrice(basePrice, reorderRate);
              return Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(dish == null ? 'Add new dish' : 'Update ${dish.name}',
                          style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: nameController,
                        decoration: const InputDecoration(labelText: 'Dish name'),
                        validator: (value) => value == null || value.trim().isEmpty
                            ? 'Name your dish so clients can find it'
                            : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: descriptionController,
                        minLines: 2,
                        maxLines: 4,
                        decoration: const InputDecoration(
                          labelText: 'Description',
                          hintText: 'What can clients expect?',
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: priceController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Price (USD)'),
                        validator: (value) {
                          final parsed = double.tryParse(value ?? '');
                          if (parsed == null || parsed <= 0) {
                            return 'Enter a valid price';
                          }
                          return null;
                        },
                        onChanged: (_) => setModalState(() {}),
                      ),
                      const SizedBox(height: 12),
                      Text('Reorder rate: ${(reorderRate * 100).round()}%',
                          style: Theme.of(context).textTheme.titleMedium),
                      Slider(
                        value: reorderRate,
                        onChanged: (value) => setModalState(() => reorderRate = value),
                        min: 0.1,
                        max: 0.95,
                        divisions: 17,
                        label: '${(reorderRate * 100).round()}%',
                      ),
                      Text(
                        'Suggested price ${formatCurrency(suggested)} based on reorder trends.',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: leadTimeController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'Lead time (minutes)',
                              ),
                              validator: (value) {
                                final parsed = int.tryParse(value ?? '');
                                if (parsed == null || parsed < 30) {
                                  return 'Minimum 30 minutes lead time';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: inventoryController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'Inventory available',
                              ),
                              validator: (value) {
                                final parsed = int.tryParse(value ?? '');
                                if (parsed == null || parsed < 0) {
                                  return 'Inventory must be zero or more';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: lowStockController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Low stock threshold',
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: ingredientsController,
                        decoration: const InputDecoration(
                          labelText: 'Key ingredients',
                          hintText: 'Comma separated list',
                        ),
                      ),
                      const SizedBox(height: 12),
                      SwitchListTile.adaptive(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Show in discovery'),
                        subtitle: const Text('Disable temporarily if you need to pause orders.'),
                        value: isPublished,
                        onChanged: (value) => setModalState(() => isPublished = value),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('Cancel'),
                          ),
                          const SizedBox(width: 12),
                          FilledButton(
                            onPressed: () {
                              if (!(formKey.currentState?.validate() ?? false)) {
                                return;
                              }
                              final parsedPrice = double.parse(priceController.text.trim());
                              final suggestedPrice = _suggestPrice(parsedPrice, reorderRate);
                              final ingredients = _parseIngredients(ingredientsController.text);
                              final updatedDish = dish == null
                                  ? Dish(
                                      id: 'dish-${DateTime.now().millisecondsSinceEpoch}',
                                      name: nameController.text.trim(),
                                      description: descriptionController.text.trim(),
                                      price: parsedPrice,
                                      suggestedPrice: suggestedPrice,
                                      leadTimeMinutes: int.parse(leadTimeController.text.trim()),
                                      ingredients: ingredients,
                                      inventory: int.parse(inventoryController.text.trim()),
                                      lowStockThreshold: int.parse(lowStockController.text.trim()),
                                      reorderRate: reorderRate,
                                      isPublished: isPublished,
                                    )
                                  : dish.copyWith(
                                      name: nameController.text.trim(),
                                      description: descriptionController.text.trim(),
                                      price: parsedPrice,
                                      suggestedPrice: suggestedPrice,
                                      leadTimeMinutes: int.parse(leadTimeController.text.trim()),
                                      ingredients: ingredients,
                                      inventory: int.parse(inventoryController.text.trim()),
                                      lowStockThreshold: int.parse(lowStockController.text.trim()),
                                      reorderRate: reorderRate,
                                      isPublished: isPublished,
                                    );
                              if (dish == null) {
                                onCreateDish(updatedDish);
                              } else {
                                onUpdateDish(updatedDish);
                              }
                              Navigator.of(context).pop();
                            },
                            child: Text(dish == null ? 'Add dish' : 'Save changes'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  static double _suggestPrice(double basePrice, double reorderRate) {
    if (basePrice <= 0) return 0;
    final multiplier = 1 + (reorderRate * 0.12);
    return double.parse((basePrice * multiplier).toStringAsFixed(2));
  }

  static List<String> _parseIngredients(String value) {
    return value
        .split(',')
        .map((ingredient) => ingredient.trim())
        .where((ingredient) => ingredient.isNotEmpty)
        .toList();
  }
}

class _DishCard extends StatelessWidget {
  const _DishCard({
    required this.dish,
    required this.onEdit,
    required this.onDelete,
    required this.onTogglePublished,
  });

  final Dish dish;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final ValueChanged<bool> onTogglePublished;

  @override
  Widget build(BuildContext context) {
    final isLowStock = dish.isLowStock;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        dish.name,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 4),
                      Text(dish.description, style: Theme.of(context).textTheme.bodyMedium),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'edit') {
                      onEdit();
                    } else if (value == 'delete') {
                      onDelete();
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem<String>(value: 'edit', child: Text('Edit')), 
                    const PopupMenuItem<String>(value: 'delete', child: Text('Remove')),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                Chip(
                  avatar: const Icon(Icons.attach_money, size: 18),
                  label: Text('Current ${formatCurrency(dish.price)}'),
                ),
                Chip(
                  avatar: const Icon(Icons.trending_up, size: 18),
                  label: Text('Suggested ${formatCurrency(dish.suggestedPrice)}'),
                ),
                Chip(
                  avatar: const Icon(Icons.timer_outlined, size: 18),
                  label: Text('${dish.leadTimeMinutes} min prep'),
                ),
                Chip(
                  avatar: const Icon(Icons.restart_alt, size: 18),
                  label: Text('${(dish.reorderRate * 100).round()}% reorder rate'),
                ),
                if (isLowStock)
                  Chip(
                    backgroundColor: brandWarning.withOpacity(0.18),
                    avatar: const Icon(Icons.warning_amber_outlined, size: 18, color: brandWarning),
                    label: const Text('Low stock'),
                    labelStyle: const TextStyle(color: brandWarning, fontWeight: FontWeight.w600),
                  )
                else
                  Chip(
                    avatar: const Icon(Icons.inventory_outlined, size: 18),
                    label: Text('${dish.inventory} portions ready'),
                  ),
              ],
            ),
            if (dish.ingredients.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (final ingredient in dish.ingredients)
                    Chip(
                      label: Text(ingredient),
                      backgroundColor: brandSurface,
                    ),
                ],
              ),
            ],
            const SizedBox(height: 12),
            SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              title: const Text('Published to clients'),
              subtitle: const Text('Toggle visibility in client discovery feed.'),
              value: dish.isPublished,
              onChanged: onTogglePublished,
            ),
          ],
        ),
      ),
    );
  }
}
