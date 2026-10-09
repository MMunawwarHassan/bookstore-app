import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/review_model.dart';

class ReviewService {
  final _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _reviews(String bookId) =>
      _db.collection('books').doc(bookId).collection('reviews');

  Stream<List<Review>> watchReviews(String bookId) =>
      _reviews(bookId).snapshots().map((s) {
        final list =
            s.docs.map((d) => Review.fromMap(d.id, d.data())).toList();
        list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        return list;
      });

  Future<void> addReview({
    required String bookId,
    required String userId,
    required String userName,
    required double rating,
    required String comment,
  }) async {
    final ref = _reviews(bookId).doc(userId);
    final old = await ref.get();
    await ref.set({
      'userId': userId,
      'userName': userName,
      'rating': rating,
      'comment': comment,
      'likes': old.exists ? (old.data()?['likes'] ?? []) : [],
      'createdAt': FieldValue.serverTimestamp(),
    });
    await _updateBookRating(bookId);
  }

  Future<void> toggleLike(String bookId, String reviewId, String uid) async {
    final ref = _reviews(bookId).doc(reviewId);
    final snap = await ref.get();
    final likes = List<String>.from(snap.data()?['likes'] ?? []);
    await ref.update({
      'likes': likes.contains(uid)
          ? FieldValue.arrayRemove([uid])
          : FieldValue.arrayUnion([uid]),
    });
  }

  Future<void> _updateBookRating(String bookId) async {
    final snap = await _reviews(bookId).get();
    if (snap.docs.isEmpty) return;
    final total = snap.docs
        .fold<double>(0, (s, d) => s + ((d.data()['rating'] ?? 0) as num));
    final avg = total / snap.docs.length;
    await _db.collection('books').doc(bookId).update({
      'rating': double.parse(avg.toStringAsFixed(1)),
      'ratingCount': snap.docs.length,
    });
  }
}