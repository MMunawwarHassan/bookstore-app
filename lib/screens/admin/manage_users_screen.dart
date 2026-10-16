import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/admin_provider.dart';
import '../../providers/auth_provider.dart';

class ManageUsersScreen extends ConsumerWidget {
  const ManageUsersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final users = ref.watch(allUsersProvider);
    final myUid = ref.watch(authServiceProvider).currentUser?.uid;

    return Scaffold(
      appBar: AppBar(title: const Text('Manage Users')),
      body: users.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (list) => ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: list.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (_, i) {
            final u = list[i];
            final role = u['role'] ?? 'user';
            final name = (u['name'] ?? 'User').toString();
            final isMe = u['uid'] == myUid;
            return Card(
              child: ListTile(
                leading: CircleAvatar(
                    child: Text(
                        name.isNotEmpty ? name[0].toUpperCase() : '?')),
                title: Text(isMe ? '$name (you)' : name),
                subtitle: Text('${u['email'] ?? ''}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Chip(label: Text(role.toString().toUpperCase())),
                    if (!isMe)
                      PopupMenuButton<String>(
                        onSelected: (r) => ref
                            .read(adminServiceProvider)
                            .setRole(u['uid'], r),
                        itemBuilder: (_) => const [
                          PopupMenuItem(
                              value: 'admin', child: Text('Make admin')),
                          PopupMenuItem(
                              value: 'user', child: Text('Make user')),
                        ],
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}