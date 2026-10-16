import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/admin_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/user_provider.dart';
import '../admin/admin_dashboard_screen.dart';
import '../orders/order_history_screen.dart';
import '../wishlist/wishlist_screen.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authServiceProvider).currentUser;
    final profile = ref.watch(userProfileProvider).value;
    final isAdmin = ref.watch(isAdminProvider);
    final cs = Theme.of(context).colorScheme;

    final name = profile?['name'] ?? user?.displayName ?? 'User';
    final address = profile?['address'] ?? 'Not added yet';
    final phone = profile?['phone'] ?? 'Not added yet';
    final payment = profile?['paymentMethod'] ?? 'Cash on Delivery';

    void go(Widget screen) =>
        Navigator.push(context, MaterialPageRoute(builder: (_) => screen));

    return Scaffold(
      appBar: AppBar(title: const Text('My Profile')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: CircleAvatar(
              radius: 44,
              backgroundColor: cs.primaryContainer,
              child: Text(
                name.toString().isNotEmpty
                    ? name.toString()[0].toUpperCase()
                    : '?',
                style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: cs.onPrimaryContainer),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: Text(name,
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold)),
          ),
          Center(
            child: Text(user?.email ?? '',
                style: TextStyle(color: cs.onSurfaceVariant)),
          ),
          if (isAdmin)
            Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Chip(
                  avatar: const Icon(Icons.verified_user, size: 16),
                  label: const Text('ADMIN'),
                ),
              ),
            ),
          const SizedBox(height: 20),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.phone_outlined),
                  title: const Text('Phone'),
                  subtitle: Text(phone),
                ),
                ListTile(
                  leading: const Icon(Icons.location_on_outlined),
                  title: const Text('Shipping address'),
                  subtitle: Text(address),
                ),
                ListTile(
                  leading: const Icon(Icons.payments_outlined),
                  title: const Text('Payment method'),
                  subtitle: Text(payment),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Column(
              children: [
                if (isAdmin)
                  ListTile(
                    leading: Icon(Icons.admin_panel_settings_outlined,
                        color: cs.primary),
                    title: const Text('Admin panel'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => go(const AdminDashboardScreen()),
                  ),
                ListTile(
                  leading: const Icon(Icons.edit_outlined),
                  title: const Text('Edit profile'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => go(const EditProfileScreen()),
                ),
                ListTile(
                  leading: const Icon(Icons.receipt_long_outlined),
                  title: const Text('My orders'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => go(const OrderHistoryScreen()),
                ),
                ListTile(
                  leading: const Icon(Icons.favorite_border),
                  title: const Text('My wishlist'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => go(const WishlistScreen()),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: Icon(Icons.logout, color: cs.error),
              title: Text('Logout', style: TextStyle(color: cs.error)),
              onTap: () {
                Navigator.of(context).popUntil((r) => r.isFirst);
                ref.read(authServiceProvider).logout();
              },
            ),
          ),
        ],
      ),
    );
  }
}