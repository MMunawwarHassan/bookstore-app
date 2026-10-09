import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../providers/order_provider.dart';
import 'order_tracking_screen.dart';

class OrderHistoryScreen extends ConsumerWidget {
  const OrderHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orders = ref.watch(userOrdersProvider);
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('My Orders')),
      body: orders.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (list) {
          if (list.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.receipt_long_outlined,
                      size: 72, color: cs.outline),
                  const SizedBox(height: 12),
                  const Text('No orders yet'),
                ],
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: list.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (_, i) {
              final o = list[i];
              return Card(
                child: ListTile(
                  leading: const Icon(Icons.local_shipping_outlined),
                  title: Text(
                      'Order #${o.id.substring(0, 6).toUpperCase()} • \$${o.total.toStringAsFixed(2)}'),
                  subtitle: Text(
                      '${DateFormat('dd MMM yyyy, hh:mm a').format(o.createdAt)}\n${o.items.length} item(s)'),
                  isThreeLine: true,
                  trailing: Chip(label: Text(o.status.toUpperCase())),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => OrderTrackingScreen(order: o)),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}