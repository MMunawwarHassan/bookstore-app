import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../models/order_model.dart';
import '../../providers/admin_provider.dart';
import '../../providers/order_provider.dart';

class ManageOrdersScreen extends ConsumerWidget {
  const ManageOrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orders = ref.watch(allOrdersProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Manage Orders')),
      body: orders.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (list) {
          if (list.isEmpty) {
            return const Center(child: Text('No orders yet'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: list.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (_, i) {
              final o = list[i];
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text('#${o.id.substring(0, 6).toUpperCase()}',
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold)),
                          const Spacer(),
                          Text('\$${o.total.toStringAsFixed(2)}',
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(DateFormat('dd MMM yyyy, hh:mm a')
                          .format(o.createdAt)),
                      const SizedBox(height: 4),
                      Text(
                          o.items
                              .map((e) => '${e.title} x${e.quantity}')
                              .join(', '),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 4),
                      Text('${o.address} • ${o.phone}',
                          style: Theme.of(context).textTheme.bodySmall),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          const Text('Status: '),
                          DropdownButton<String>(
                            value: o.status,
                            items: [
                              for (final s in OrderModel.statuses)
                                DropdownMenuItem(
                                    value: s, child: Text(s.toUpperCase())),
                            ],
                            onChanged: (v) {
                              if (v != null) {
                                ref
                                    .read(orderServiceProvider)
                                    .updateStatus(o.id, v);
                              }
                            },
                          ),
                        ],
                      ),
                    ],
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