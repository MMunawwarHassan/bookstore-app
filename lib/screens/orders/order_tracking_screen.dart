import 'package:flutter/material.dart';
import '../../models/order_model.dart';
import '../../widgets/status_chip.dart';

class OrderTrackingScreen extends StatelessWidget {
  final OrderModel order;
  const OrderTrackingScreen({super.key, required this.order});

  static const _labels = {
    'placed': 'Order Placed',
    'processing': 'Processing',
    'shipped': 'Shipped',
    'delivered': 'Delivered',
  };

  static const _icons = {
    'placed': Icons.receipt_long,
    'processing': Icons.inventory_2_outlined,
    'shipped': Icons.local_shipping_outlined,
    'delivered': Icons.check_circle_outline,
  };

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final current = OrderModel.statuses.indexOf(order.status);
    final accent = StatusChip.colorFor(order.status);

    return Scaffold(
      appBar: AppBar(
          title: Text('Order #${order.id.substring(0, 6).toUpperCase()}')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text('Delivery Status',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold)),
                      const Spacer(),
                      StatusChip(status: order.status),
                    ],
                  ),
                  const SizedBox(height: 20),
                  for (var i = 0; i < OrderModel.statuses.length; i++)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          children: [
                            Container(
                              width: 34,
                              height: 34,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: i <= current
                                    ? accent
                                    : cs.surfaceContainerHighest,
                              ),
                              child: Icon(
                                _icons[OrderModel.statuses[i]],
                                size: 18,
                                color:
                                    i <= current ? Colors.white : cs.outline,
                              ),
                            ),
                            if (i < OrderModel.statuses.length - 1)
                              Container(
                                width: 3,
                                height: 34,
                                color: i < current
                                    ? accent
                                    : cs.outlineVariant,
                              ),
                          ],
                        ),
                        const SizedBox(width: 14),
                        Padding(
                          padding: const EdgeInsets.only(top: 7),
                          child: Text(
                            _labels[OrderModel.statuses[i]]!,
                            style: TextStyle(
                              fontWeight: i == current
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: i <= current ? null : cs.outline,
                            ),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Items',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  for (final it in order.items)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(it.coverUrl,
                                width: 44,
                                height: 62,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) =>
                                    const Icon(Icons.book)),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(it.title,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w600)),
                                Text('Qty: ${it.quantity}',
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: cs.onSurfaceVariant)),
                              ],
                            ),
                          ),
                          Text(
                              '\$${(it.price * it.quantity).toStringAsFixed(2)}',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      Text('\$${order.total.toStringAsFixed(2)}',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: cs.primary)),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: Icon(Icons.location_on_outlined, color: cs.primary),
              title: const Text('Shipping to'),
              subtitle: Text('${order.address}\n${order.phone}'),
              isThreeLine: true,
            ),
          ),
        ],
      ),
    );
  }
}