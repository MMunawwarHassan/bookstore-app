import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/book_model.dart';
import '../../providers/book_provider.dart';
import '../catalog/book_details_screen.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  String _query = '';
  String _sort = 'popularity';

  @override
  Widget build(BuildContext context) {
    final books = ref.watch(booksProvider);
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Search')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              autofocus: false,
              onChanged: (v) => setState(() => _query = v.trim().toLowerCase()),
              decoration: const InputDecoration(
                hintText: 'Search by title, author or genre',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          SizedBox(
            height: 42,
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              children: [
                for (final s in const {
                  'popularity': 'Popular',
                  'price_low': 'Price: Low to High',
                  'price_high': 'Price: High to Low',
                  'newest': 'Newest',
                }.entries)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(s.value),
                      selected: _sort == s.key,
                      onSelected: (_) => setState(() => _sort = s.key),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: books.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (list) {
                var result = list.where((b) {
                  if (_query.isEmpty) return true;
                  return b.title.toLowerCase().contains(_query) ||
                      b.author.toLowerCase().contains(_query) ||
                      b.genre.toLowerCase().contains(_query);
                }).toList();

                switch (_sort) {
                  case 'price_low':
                    result.sort((a, b) => a.price.compareTo(b.price));
                  case 'price_high':
                    result.sort((a, b) => b.price.compareTo(a.price));
                  case 'newest':
                    result.sort((a, b) => b.createdAt.compareTo(a.createdAt));
                  default:
                    result.sort((a, b) => b.popularity.compareTo(a.popularity));
                }

                if (result.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.search_off, size: 64, color: cs.outline),
                        const SizedBox(height: 8),
                        const Text('No books found'),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: result.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (_, i) => _tile(result[i]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _tile(Book b) {
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
        title: Text(b.title, maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Text('${b.author} • ${b.genre}'),
        trailing: Text('\$${b.price.toStringAsFixed(0)}',
            style: const TextStyle(fontWeight: FontWeight.bold)),
        onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => BookDetailsScreen(book: b))),
      ),
    );
  }
}