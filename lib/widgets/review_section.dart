import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/auth_provider.dart';
import '../providers/review_provider.dart';

class ReviewSection extends ConsumerWidget {
  final String bookId;
  const ReviewSection({super.key, required this.bookId});

  void _openForm(BuildContext context, WidgetRef ref) {
    final user = ref.read(authServiceProvider).currentUser;
    if (user == null) return;
    final comment = TextEditingController();
    double rating = 5;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) => Padding(
          padding: EdgeInsets.fromLTRB(
              20, 8, 20, MediaQuery.of(ctx).viewInsets.bottom + 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Write a Review',
                  style: Theme.of(ctx).textTheme.titleLarge),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (var i = 1; i <= 5; i++)
                    IconButton(
                      iconSize: 36,
                      onPressed: () => setSheet(() => rating = i.toDouble()),
                      icon: Icon(
                        i <= rating
                            ? Icons.star_rounded
                            : Icons.star_outline_rounded,
                        color: Colors.amber,
                      ),
                    ),
                ],
              ),
              TextField(
                controller: comment,
                maxLines: 3,
                decoration:
                    const InputDecoration(hintText: 'Share your thoughts...'),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  if (comment.text.trim().isEmpty) return;
                  await ref.read(reviewServiceProvider).addReview(
                        bookId: bookId,
                        userId: user.uid,
                        userName: user.displayName ?? user.email ?? 'User',
                        rating: rating,
                        comment: comment.text.trim(),
                      );
                  if (ctx.mounted) Navigator.pop(ctx);
                },
                child: const Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reviews = ref.watch(reviewsProvider(bookId));
    final uid = ref.watch(authServiceProvider).currentUser?.uid;
    final cs = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('Reviews', style: Theme.of(context).textTheme.titleMedium),
            const Spacer(),
            TextButton.icon(
              onPressed: () => _openForm(context, ref),
              icon: const Icon(Icons.rate_review_outlined),
              label: const Text('Write review'),
            ),
          ],
        ),
        reviews.when(
          loading: () => const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (e, _) => Text('Error: $e'),
          data: (list) {
            if (list.isEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text('No reviews yet. Be the first!',
                    style: TextStyle(color: cs.onSurfaceVariant)),
              );
            }
            return Column(
              children: [
                for (final r in list)
                  Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 16,
                                child: Text(r.userName.isNotEmpty
                                    ? r.userName[0].toUpperCase()
                                    : '?'),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(r.userName,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w600)),
                                    Text(
                                      DateFormat('dd MMM yyyy')
                                          .format(r.createdAt),
                                      style: TextStyle(
                                          fontSize: 11,
                                          color: cs.onSurfaceVariant),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(Icons.star_rounded,
                                  size: 18, color: Colors.amber),
                              Text(' ${r.rating.toStringAsFixed(1)}'),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(r.comment),
                          const SizedBox(height: 4),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton.icon(
                              onPressed: uid == null
                                  ? null
                                  : () => ref
                                      .read(reviewServiceProvider)
                                      .toggleLike(bookId, r.id, uid),
                              icon: Icon(
                                r.likes.contains(uid)
                                    ? Icons.thumb_up
                                    : Icons.thumb_up_outlined,
                                size: 18,
                              ),
                              label: Text('${r.likes.length}'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}