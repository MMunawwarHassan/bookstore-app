import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/book_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/wishlist_provider.dart';
import '../../widgets/review_section.dart';
import '../cart/cart_screen.dart';

class BookDetailsScreen extends ConsumerStatefulWidget {
  final Book book;
  const BookDetailsScreen({super.key, required this.book});

  @override
  ConsumerState<BookDetailsScreen> createState() => _BookDetailsScreenState();
}

class _BookDetailsScreenState extends ConsumerState<BookDetailsScreen> {
  int _qty = 1;

  Book get book => widget.book;

  void _addToCart() {
    final notifier = ref.read(cartProvider.notifier);
    for (var i = 0; i < _qty; i++) {
      notifier.add(book);
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$_qty x ${book.title} added to cart'),
        action: SnackBarAction(
          label: 'VIEW',
          onPressed: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => const CartScreen())),
        ),
      ),
    );
    setState(() => _qty = 1);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final count = ref.watch(cartCountProvider);
    final ids = ref.watch(wishlistIdsProvider).value ?? <String>{};
    final inWishlist = ids.contains(book.id);
    final uid = ref.watch(authServiceProvider).currentUser?.uid;

    return Scaffold(
      bottomNavigationBar: _bottomBar(cs),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 380,
            backgroundColor: cs.primary,
            foregroundColor: Colors.white,
            title: Text(book.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.white, fontSize: 16)),
            actions: [
              IconButton(
                tooltip: inWishlist ? 'Remove from wishlist' : 'Add to wishlist',
                icon: Icon(
                  inWishlist ? Icons.favorite : Icons.favorite_border,
                  color: inWishlist ? Colors.redAccent : Colors.white,
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
                  child: const Icon(Icons.shopping_bag_outlined,
                      color: Colors.white),
                ),
                onPressed: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const CartScreen())),
              ),
              const SizedBox(width: 4),
            ],
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.parallax,
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [cs.primary, const Color(0xFF7C3AED)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 40, bottom: 24),
                    child: Center(
                      child: Hero(
                        tag: 'cover_${book.id}',
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.35),
                                blurRadius: 24,
                                offset: const Offset(0, 12),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(18),
                            child: CachedNetworkImage(
                              imageUrl: book.coverUrl,
                              height: 280,
                              fit: BoxFit.cover,
                              placeholder: (_, __) => Container(
                                  height: 280,
                                  width: 190,
                                  color: Colors.white24),
                              errorWidget: (_, __, ___) => Container(
                                height: 280,
                                width: 190,
                                color: Colors.white24,
                                child: const Icon(Icons.book,
                                    size: 60, color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 640),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(book.title,
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text('by ${book.author}',
                          style: TextStyle(
                              color: cs.onSurfaceVariant, fontSize: 15)),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          _infoTile(
                              Icons.star_rounded,
                              Colors.amber,
                              book.rating.toStringAsFixed(1),
                              'Rating'),
                          const SizedBox(width: 12),
                          _infoTile(Icons.reviews_outlined, cs.primary,
                              '${book.ratingCount}', 'Reviews'),
                          const SizedBox(width: 12),
                          _infoTile(Icons.category_outlined, cs.secondary,
                              book.genre, 'Genre'),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Text('About this book',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text(book.description,
                          style: TextStyle(
                              height: 1.6, color: cs.onSurfaceVariant)),
                      const SizedBox(height: 28),
                      const Divider(),
                      const SizedBox(height: 12),
                      ReviewSection(bookId: book.id),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoTile(IconData icon, Color color, String value, String label) {
    final cs = Theme.of(context).colorScheme;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: cs.outlineVariant),
        ),
        child: Column(
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 6),
            Text(value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.bold)),
            Text(label,
                style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }

  Widget _bottomBar(ColorScheme cs) {
    final total = book.price * _qty;
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(top: BorderSide(color: cs.outlineVariant)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                color: cs.primaryContainer,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove),
                    onPressed:
                        _qty > 1 ? () => setState(() => _qty--) : null,
                  ),
                  Text('$_qty',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16)),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () => setState(() => _qty++),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.shopping_bag_outlined),
                label: Text('Add  •  \$${total.toStringAsFixed(2)}'),
                onPressed: _addToCart,
              ),
            ),
          ],
        ),
      ),
    );
  }
}