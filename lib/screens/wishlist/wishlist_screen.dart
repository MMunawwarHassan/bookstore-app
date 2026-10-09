import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';
import '../../providers/book_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/wishlist_provider.dart';
import '../catalog/book_details_screen.dart';

class WishlistScreen extends ConsumerWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final books = ref.watch(booksProvider);
    final ids = ref.watch(wishlistIdsProvider).value ?? <String>{};
    final uid = ref.watch(authServiceProvider).currentUser?.uid;
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('My Wishlist')),
      body: books.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (list) {
          final items = list.where((b) => ids.contains(b.id)).toList();

          if (items.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.favorite_border, size: 72, color: cs.outline),
                  const SizedBox(height: 12),
                  const Text('Your wishlist is empty'),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (_, i) {
              final b = items[i];
              return Card(
                child: ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: Image.network(b.coverUrl,
                        width: 44,
                        height: 60,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(Icons.book)),
                  ),
                  title: Text(b.title,
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                  subtitle:
                      Text('${b.author}\n\$${b.price.toStringAsFixed(2)}'),
                  isThreeLine: true,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => BookDetailsScreen(book: b)),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        tooltip: 'Add to cart',
                        icon: const Icon(Icons.add_shopping_cart),
                        onPressed: () {
                          ref.read(cartProvider.notifier).add(b);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text('${b.title} added to cart')),
                          );
                        },
                      ),
                      IconButton(
                        tooltip: 'Remove',
                        icon: const Icon(Icons.favorite, color: Colors.red),
                        onPressed: uid == null
                            ? null
                            : () => ref
                                .read(wishlistServiceProvider)
                                .toggle(uid, b.id, true),
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