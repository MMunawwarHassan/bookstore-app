import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/cart_item_model.dart';
import '../models/order_model.dart';

class OrderService {
  final _col = FirebaseFirestore.instance.collection('orders');

  Future<void> placeOrder({
    required String userId,
    required List<CartItem> items,
    required double total,
    required String address,
    required String phone,
  }) async {
    await _col.add({
      'userId': userId,
      'items': items
          .map((c) => OrderItem(
                bookId: c.book.id,
                title: c.book.title,
                coverUrl: c.book.coverUrl,
                price: c.book.price,
                quantity: c.quantity,
              ).toMap())
          .toList(),
      'total': total,
      'status': 'placed',
      'address': address,
      'phone': phone,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // Sorting app mein ki hai, taake Firestore index ki zaroorat na pare
  Stream<List<OrderModel>> watchUserOrders(String userId) => _col
      .where('userId', isEqualTo: userId)
      .snapshots()
      .map((s) {
        final list =
            s.docs.map((d) => OrderModel.fromMap(d.id, d.data())).toList();
        list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        return list;
      });

  Stream<List<OrderModel>> watchAllOrders() => _col.snapshots().map((s) {
        final list =
            s.docs.map((d) => OrderModel.fromMap(d.id, d.data())).toList();
        list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        return list;
      });

  Future<void> updateStatus(String orderId, String status) =>
      _col.doc(orderId).update({'status': status});
}