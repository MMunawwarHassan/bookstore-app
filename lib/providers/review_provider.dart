import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/review_model.dart';
import '../services/review_service.dart';

final reviewServiceProvider = Provider((ref) => ReviewService());

final reviewsProvider =
    StreamProvider.family<List<Review>, String>((ref, bookId) {
  return ref.watch(reviewServiceProvider).watchReviews(bookId);
});