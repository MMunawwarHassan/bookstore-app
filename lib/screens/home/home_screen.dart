import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';
import '../../models/book_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/book_provider.dart';
import '../../providers/nav_provider.dart';
import '../../providers/user_provider.dart';
import '../../widgets/book_card.dart';
import '../catalog/book_details_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  String _genre = 'All';

  void _openBook(Book b) => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => BookDetailsScreen(book: b)),
      );

  @override
  Widget build(BuildContext context) {
    final books = ref.watch(booksProvider);
    final profile = ref.watch(userProfileProvider).value;
    final user = ref.watch(authServiceProvider).currentUser;
    final fullName =
        (profile?['name'] ?? user?.displayName ?? 'Reader').toString();
    final firstName = fullName.trim().split(' ').first;

    return Scaffold(
      body: SafeArea(
        child: books.when(
          loading: () => const _HomeSkeleton(),
          error: (e, _) => Center(child: Text('Error: $e')),
          data: (list) {
            if (list.isEmpty) return _emptyState();

            final genres = ['All', ...{...list.map((b) => b.genre)}];
            final filtered = _genre == 'All'
                ? list
                : list.where((b) => b.genre == _genre).toList();
            final bestsellers =
                filtered.where((b) => b.isBestseller).toList();
            final newArrivals = [...filtered]
              ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
            final topRated = [...filtered]
              ..sort((a, b) => b.rating.compareTo(a.rating));

            return ListView(
              padding: const EdgeInsets.only(bottom: 24),
              children: [
                _header(firstName),
                _searchBar(),
                _banner(list.length),
                const SizedBox(height: 20),
                SizedBox(
                  height: 40,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    scrollDirection: Axis.horizontal,
                    itemCount: genres.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (_, i) => ChoiceChip(
                      label: Text(genres[i]),
                      selected: _genre == genres[i],
                      showCheckmark: false,
                      onSelected: (_) => setState(() => _genre = genres[i]),
                    ),
                  ),
                ),
                _section('Bestsellers', bestsellers),
                _section('New Arrivals', newArrivals.take(10).toList()),
                _section('Top Rated', topRated.take(10).toList()),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _header(String name) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Hello, $name 👋',
                    style: TextStyle(color: cs.onSurfaceVariant)),
                const SizedBox(height: 2),
                Text('Find your next read',
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => ref.read(tabIndexProvider.notifier).set(4),
            child: CircleAvatar(
              radius: 22,
              backgroundColor: cs.primaryContainer,
              child: Text(
                name.isNotEmpty ? name[0].toUpperCase() : '?',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: cs.onPrimaryContainer),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _searchBar() {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
      child: GestureDetector(
        onTap: () => ref.read(tabIndexProvider.notifier).set(1),
        child: Container(
          height: 52,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardTheme.color,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: cs.outlineVariant),
          ),
          child: Row(
            children: [
              Icon(Icons.search, color: cs.onSurfaceVariant),
              const SizedBox(width: 10),
              Text('Search title, author or genre',
                  style: TextStyle(color: cs.onSurfaceVariant)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _banner(int total) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          gradient: LinearGradient(
            colors: [cs.primary, const Color(0xFF7C3AED)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Discover $total+ books',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Text('Bestsellers, new arrivals and more',
                      style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.85))),
                  const SizedBox(height: 14),
                  FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: cs.primary,
                    ),
                    onPressed: () =>
                        ref.read(tabIndexProvider.notifier).set(1),
                    child: const Text('Browse now'),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Icon(Icons.auto_stories_rounded,
                size: 72, color: Colors.white.withValues(alpha: 0.9)),
          ],
        ),
      ),
    );
  }

  Widget _section(String title, List<Book> items) {
    if (items.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
          child: Text(title,
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold)),
        ),
        SizedBox(
          height: 285,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            scrollDirection: Axis.horizontal,
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(width: 14),
            itemBuilder: (_, i) =>
                BookCard(book: items[i], onTap: () => _openBook(items[i])),
          ),
        ),
      ],
    );
  }

  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.menu_book_outlined, size: 64),
          const SizedBox(height: 12),
          const Text('No books yet'),
          const SizedBox(height: 12),
          ElevatedButton(
            style: ElevatedButton.styleFrom(minimumSize: const Size(220, 48)),
            onPressed: () => ref.read(bookServiceProvider).seedBooks(),
            child: const Text('Add 20 sample books'),
          ),
        ],
      ),
    );
  }
}

class _HomeSkeleton extends StatelessWidget {
  const _HomeSkeleton();

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final base = dark ? const Color(0xFF2A2A35) : const Color(0xFFE5E3EE);
    final high = dark ? const Color(0xFF3A3A48) : const Color(0xFFF5F4FA);

    Widget box(double w, double h, [double r = 14]) => Container(
          width: w,
          height: h,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(r),
          ),
        );

    return Shimmer.fromColors(
      baseColor: base,
      highlightColor: high,
      child: ListView(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        children: [
          box(180, 20),
          const SizedBox(height: 10),
          box(240, 28),
          const SizedBox(height: 20),
          box(double.infinity, 52),
          const SizedBox(height: 16),
          box(double.infinity, 140, 22),
          const SizedBox(height: 28),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const NeverScrollableScrollPhysics(),
            child: Row(
              children: [
                for (var i = 0; i < 4; i++) ...[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      box(140, 190),
                      const SizedBox(height: 8),
                      box(100, 14, 6),
                      const SizedBox(height: 6),
                      box(70, 12, 6),
                    ],
                  ),
                  const SizedBox(width: 14),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}