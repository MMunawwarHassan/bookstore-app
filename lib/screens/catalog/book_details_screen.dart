import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/book_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/wishlist_provider.dart';
import '../../widgets/review_section.dart';
import '../cart/cart_screen.dart';

class BookDetailsScreen extends ConsumerWidget {
  final Book book;
  const BookDetailsScreen({super.key, required this.book});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final count = ref.watch(cartCountProvider);
    final ids = ref.watch(wishlistIdsProvider).value ?? <String>{};
    final inWishlist = ids.contains(book.id);
    final uid = ref.watch(authServiceProvider).currentUser?.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Details'),
        actions: [
          IconButton(
            tooltip: inWishlist ? 'Remove from wishlist' : 'Add to wishlist',
            icon: Icon(
              inWishlist ? Icons.favorite : Icons.favorite_border,
              color: inWishlist ? Colors.red : null,
            ),
            onPressed: uid == null
                ? null
                : () => ref
                    .read(wishlistServiceProvider)
                    .toggle(uid, book.id, inWishlist),
          ),
          IconButton(
            icon: Badge(
              isLabelVisible: count > 0,
              label: Text('$count'),
              child: const Icon(Icons.shopping_cart_outlined),
            ),
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const CartScreen())),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton.icon(
            icon: const Icon(Icons.add_shopping_cart),
            label: const Text('Add to Cart'),
            onPressed: () {
              ref.read(cartProvider.notifier).add(book);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${book.title} added to cart')),
              );
            },
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Hero(
                    tag: 'cover_${book.id}',
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: CachedNetworkImage(
                        imageUrl: book.coverUrl,
                        height: 320,
                        fit: BoxFit.cover,
                        errorWidget: (_, __, ___) => Container(
                          height: 320,
                          width: 220,
                          color: cs.surfaceContainerHighest,
                          child: const Icon(Icons.book, size: 60),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(book.title,
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text('by ${book.author}',
                    style: TextStyle(color: cs.onSurfaceVariant)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.star_rounded, color: Colors.amber),
                    Text(' ${book.rating}  (${book.ratingCount} reviews)'),
                    const Spacer(),
                    Chip(label: Text(book.genre)),
                  ],
                ),
                const SizedBox(height: 12),
                Text('\$${book.price.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: cs.primary, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                Text('Description',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                Text(book.description),
                const SizedBox(height: 24),
                ReviewSection(bookId: book.id),
              ],
            ),
          ),
        ),
      ),
    );
  }
}