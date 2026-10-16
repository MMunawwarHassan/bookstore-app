import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/admin_provider.dart';
import '../../providers/book_provider.dart';
import 'manage_books_screen.dart';
import 'manage_orders_screen.dart';
import 'manage_users_screen.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final books = ref.watch(booksProvider).value?.length ?? 0;
    final orders = ref.watch(allOrdersProvider).value ?? [];
    final users = ref.watch(allUsersProvider).value?.length ?? 0;
    final revenue = orders
        .where((o) => o.status == 'delivered')
        .fold<double>(0, (s, o) => s + o.total);
    final pending = orders.where((o) => o.status != 'delivered').length;

    void go(Widget s) =>
        Navigator.push(context, MaterialPageRoute(builder: (_) => s));

    Widget stat(String label, String value, IconData icon) => Expanded(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(icon, color: Theme.of(context).colorScheme.primary),
                  const SizedBox(height: 8),
                  Text(value,
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold)),
                  Text(label),
                ],
              ),
            ),
          ),
        );

    return Scaffold(
      appBar: AppBar(title: const Text('Admin Dashboard')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(children: [
            stat('Books', '$books', Icons.menu_book),
            stat('Users', '$users', Icons.people_outline),
          ]),
          Row(children: [
            stat('Orders', '${orders.length}', Icons.receipt_long),
            stat('Pending', '$pending', Icons.pending_actions),
          ]),
          Row(children: [
            stat('Revenue (delivered)', '\$${revenue.toStringAsFixed(0)}',
                Icons.payments_outlined),
          ]),
          const SizedBox(height: 12),
          Card(
            child: Column(children: [
              ListTile(
                leading: const Icon(Icons.library_books_outlined),
                title: const Text('Manage books'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => go(const ManageBooksScreen()),
              ),
              ListTile(
                leading: const Icon(Icons.local_shipping_outlined),
                title: const Text('Manage orders'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => go(const ManageOrdersScreen()),
              ),
              ListTile(
                leading: const Icon(Icons.manage_accounts_outlined),
                title: const Text('Manage users'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => go(const ManageUsersScreen()),
              ),
            ]),
          ),
        ],
      ),
    );
  }
}