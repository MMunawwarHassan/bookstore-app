import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../models/book_model.dart';

class BookDetailsScreen extends StatelessWidget {
  final Book book;
  const BookDetailsScreen({super.key, required this.book});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Book Details')),
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}