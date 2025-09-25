import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../constants.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_time_extensions.dart';
import '../../../../localization/app_localizations.dart';
import '../../../../localization/localization_extension.dart';
import '../../../discovery/presentation/discovery_controller.dart';
import '../../../menu/domain/menu_item.dart';
import '../../domain/order_models.dart';
import '../orders_controller.dart';
import 'support_chat_screen.dart';

class OrderDetailScreen extends StatefulWidget {
  const OrderDetailScreen({
    super.key,
    required this.controller,
    required this.orderId,
    required this.discoveryController,
  });

  final OrdersController controller;
  final String orderId;
  final DiscoveryController discoveryController;

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  MenuItem? _menuItem;
  bool _loadingMenu = true;
  final CurrencyFormatter _currency = CurrencyFormatter();
  final DateTimeFormatter _formatter = const DateTimeFormatter();

  @override
  void initState() {
    super.initState();
    final order = _currentOrder;
    if (order != null) {
      final cached = widget.discoveryController.findMenuItem(order.chefId, order.menuItemId);
      if (cached != null) {
        setState(() {
          _menuItem = cached;
          _loadingMenu = false;
        });
      } else {
        widget.discoveryController
            .fetchMenuItem(order.chefId, order.menuItemId)
            .then((value) => setState(() {
                  _menuItem = value;
                  _loadingMenu = false;
                }));
      }
      widget.controller.selectOrder(order);
    }
  }

  OrderSummary? get _currentOrder {
    final orders = widget.controller.orders;
    if (orders.isEmpty) return widget.controller.selected;
    for (final order in orders) {
      if (order.orderId == widget.orderId) {
        return order;
      }
    }
    return widget.controller.selected ?? orders.first;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) {
        final order = _currentOrder;
        if (order == null) {
          return Scaffold(
            appBar: AppBar(),
            body: Center(child: Text(l10n.translate('emptyOrders'))),
          );
        }
        final timeline = order.timeline;
        return Scaffold(
          appBar: AppBar(title: Text('Order ${order.orderId}')),
          body: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              if (_loadingMenu)
                const LinearProgressIndicator()
              else if (_menuItem != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_menuItem!.photo.isNotEmpty)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: Image.network(_menuItem!.photo, fit: BoxFit.cover),
                      ),
                    const SizedBox(height: 16),
                    Text(_menuItem!.name, style: Theme.of(context).textTheme.headlineSmall),
                    const SizedBox(height: 8),
                    Text(_menuItem!.description),
                    const SizedBox(height: 16),
                  ],
                ),
              Text(l10n.translate('statusTimeline'), style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),
              ...timeline.map((update) {
                final label = _statusLabel(l10n, update.status);
                return ListTile(
                  leading: const Icon(Icons.check_circle, color: AppColors.primary),
                  title: Text(label),
                  subtitle: Text(_formatter.formatDay(update.changedAt)),
                );
              }),
              const Divider(height: 32),
              _SummaryChip(label: l10n.translate('totalDue'), value: _currency.format(order.total)),
              _SummaryChip(label: l10n.translate('groceryAdvance'), value: _currency.format(order.groceryAdvance)),
              _SummaryChip(label: l10n.translate('remainingBalance'), value: _currency.format(order.remainingBalance)),
              const SizedBox(height: 24),
              if (order.status == 'delivered')
                ElevatedButton(
                  onPressed: () => widget.controller.confirmDelivery(order.orderId),
                  child: Text(l10n.translate('confirmDelivery')),
                )
              else if (order.status == 'dispatched')
                ElevatedButton(
                  onPressed: () => widget.controller.confirmDelivery(order.orderId),
                  child: Text(l10n.translate('confirmDelivery')),
                ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () => _showIssueSheet(order.orderId),
                child: Text(l10n.translate('reportIssue')),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const SupportChatScreen()),
                ),
                child: Text(l10n.translate('openChat')),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => _showRatingSheet(order.orderId),
                child: Text(l10n.translate('leaveReview')),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showIssueSheet(String orderId) {
    final l10n = context.l10n;
    final controller = TextEditingController();
    XFile? pickedImage;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.translate('issueDetailsLabel'), style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: l10n.translate('issueDetailsLabel'),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: () async {
                      final picker = ImagePicker();
                      pickedImage = await picker.pickImage(source: ImageSource.gallery);
                      setState(() {});
                    },
                    icon: const Icon(Icons.camera_alt_outlined),
                    label: Text(l10n.translate('uploadProof')),
                  ),
                  if (pickedImage != null) ...[
                    const SizedBox(width: 12),
                    Expanded(child: Text(pickedImage!.name, overflow: TextOverflow.ellipsis)),
                  ],
                ],
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  widget.controller.reportIssue(orderId, controller.text);
                  Navigator.of(context).pop();
                },
                child: Text(l10n.translate('submit')),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showRatingSheet(String orderId) {
    final l10n = context.l10n;
    double rating = 5;
    final controller = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: StatefulBuilder(
            builder: (context, setModalState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.translate('ratingPrompt'), style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 12),
                  Slider(
                    value: rating,
                    min: 1,
                    max: 5,
                    divisions: 4,
                    label: rating.toStringAsFixed(1),
                    onChanged: (value) => setModalState(() => rating = value),
                  ),
                  TextField(
                    controller: controller,
                    maxLines: 3,
                    decoration: InputDecoration(hintText: l10n.translate('leaveReview')),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      widget.controller.submitRating(orderId, rating.round(), report: controller.text);
                      Navigator.of(context).pop();
                    },
                    child: Text(l10n.translate('submit')),
                  ),
                ],
              );
            },
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

class _SummaryChip extends StatelessWidget {
  const _SummaryChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
