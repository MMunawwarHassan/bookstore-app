import 'package:cloud_firestore/cloud_firestore.dart';

class WishlistService {
  final _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _col(String uid) =>
      _db.collection('wishlists').doc(uid).collection('books');

  // Wishlist mein maujood books ki ids
  Stream<Set<String>> watchIds(String uid) => _col(uid)
      .snapshots()
      .map((s) => s.docs.map((d) => d.id).toSet());

  Future<void> toggle(String uid, String bookId, bool inWishlist) async {
    final ref = _col(uid).doc(bookId);
    if (inWishlist) {
      await ref.delete();
    } else {
      await ref.set({
        'bookId': bookId,
        'addedAt': FieldValue.serverTimestamp(),
      });
    }
  }
}