import 'package:flutter/material.dart';
import '../../models/order_model.dart';

class OrderTrackingScreen extends StatelessWidget {
  final OrderModel order;
  const OrderTrackingScreen({super.key, required this.order});

  static const _labels = {
    'placed': 'Order Placed',
    'processing': 'Processing',
    'shipped': 'Shipped',
    'delivered': 'Delivered',
  };

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final current = OrderModel.statuses.indexOf(order.status);

    return Scaffold(
      appBar: AppBar(
          title: Text('Order #${order.id.substring(0, 6).toUpperCase()}')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text('Delivery Status',
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          for (var i = 0; i < OrderModel.statuses.length; i++)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    CircleAvatar(
                      radius: 14,
                      backgroundColor:
                          i <= current ? cs.primary : cs.surfaceContainerHighest,
                      child: Icon(Icons.check,
                          size: 16,
                          color: i <= current ? Colors.white : cs.outline),
                    ),
                    if (i < OrderModel.statuses.length - 1)
                      Container(
                        width: 2,
                        height: 36,
                        color: i < current ? cs.primary : cs.outlineVariant,
                      ),
                  ],
                ),
                const SizedBox(width: 14),
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    _labels[OrderModel.statuses[i]]!,
                    style: TextStyle(
                      fontWeight:
                          i == current ? FontWeight.bold : FontWeight.normal,
                      color: i <= current ? null : cs.outline,
                    ),
                  ),
                ),
              ],
            ),
          const Divider(height: 40),
          Text('Items', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          for (final it in order.items)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: Image.network(it.coverUrl,
                    width: 40,
                    height: 56,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Icon(Icons.book)),
              ),
              title: Text(it.title),
              subtitle: Text('Qty: ${it.quantity}'),
              trailing: Text('\$${(it.price * it.quantity).toStringAsFixed(2)}'),
            ),
          const Divider(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              Text('\$${order.total.toStringAsFixed(2)}',
                  style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 20),
          Text('Shipping to', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(order.address),
          Text(order.phone),
        ],
      ),
    );
  }
}