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

    final name = (profile?['name'] ?? user?.displayName ?? 'User').toString();
    final address = (profile?['address'] ?? 'Not added yet').toString();
    final phone = (profile?['phone'] ?? 'Not added yet').toString();
    final payment =
        (profile?['paymentMethod'] ?? 'Cash on Delivery').toString();

    void go(Widget screen) =>
        Navigator.push(context, MaterialPageRoute(builder: (_) => screen));

    Widget menu(IconData icon, String title, VoidCallback onTap,
            {Color? color}) =>
        ListTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: (color ?? cs.primary).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: color ?? cs.primary),
          ),
          title: Text(title),
          trailing: const Icon(Icons.chevron_right),
          onTap: onTap,
        );

    Widget info(IconData icon, String label, String value) => ListTile(
          leading: Icon(icon, color: cs.onSurfaceVariant),
          title: Text(label,
              style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant)),
          subtitle: Text(value,
              style: TextStyle(
                  fontSize: 15,
                  color: cs.onSurface,
                  fontWeight: FontWeight.w500)),
        );

    return Scaffold(
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [cs.primary, const Color(0xFF7C3AED)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(36)),
            ),
            child: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  const Text('My Profile',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600)),
                  const SizedBox(height: 20),
                  CircleAvatar(
                    radius: 44,
                    backgroundColor: Colors.white,
                    child: Text(
                      name.isNotEmpty ? name[0].toUpperCase() : '?',
                      style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: cs.primary),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(name,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold)),
                  Text(user?.email ?? '',
                      style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.85))),
                  if (isAdmin)
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.verified_user,
                                size: 14, color: Colors.white),
                            SizedBox(width: 6),
                            Text('ADMIN',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Card(
                  child: Column(
                    children: [
                      info(Icons.phone_outlined, 'Phone', phone),
                      info(Icons.location_on_outlined, 'Shipping address',
                          address),
                      info(Icons.payments_outlined, 'Payment method',
                          payment),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Card(
                  child: Column(
                    children: [
                      if (isAdmin)
                        menu(Icons.admin_panel_settings_outlined,
                            'Admin panel',
                            () => go(const AdminDashboardScreen())),
                      menu(Icons.edit_outlined, 'Edit profile',
                          () => go(const EditProfileScreen())),
                      menu(Icons.receipt_long_outlined, 'My orders',
                          () => go(const OrderHistoryScreen())),
                      menu(Icons.favorite_border, 'My wishlist',
                          () => go(const WishlistScreen())),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Card(
                  child: menu(Icons.logout, 'Logout', () async {
                    final ok = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Logout?'),
                        content: const Text(
                            'Are you sure you want to logout?'),
                        actions: [
                          TextButton(
                              onPressed: () => Navigator.pop(ctx, false),
                              child: const Text('Cancel')),
                          TextButton(
                              onPressed: () => Navigator.pop(ctx, true),
                              child: const Text('Logout')),
                        ],
                      ),
                    );
                    if (ok == true) {
                      ref.read(authServiceProvider).logout();
                    }
                  }, color: cs.error),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ],
      ),
    );
  }
}