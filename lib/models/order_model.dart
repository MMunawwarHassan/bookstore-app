import 'package:cloud_firestore/cloud_firestore.dart';

class OrderItem {
  final String bookId;
  final String title;
  final String coverUrl;
  final double price;
  final int quantity;

  OrderItem({
    required this.bookId,
    required this.title,
    required this.coverUrl,
    required this.price,
    required this.quantity,
  });

  factory OrderItem.fromMap(Map<String, dynamic> m) => OrderItem(
        bookId: m['bookId'] ?? '',
        title: m['title'] ?? '',
        coverUrl: m['coverUrl'] ?? '',
        price: (m['price'] ?? 0).toDouble(),
        quantity: m['quantity'] ?? 1,
      );

  Map<String, dynamic> toMap() => {
        'bookId': bookId,
        'title': title,
        'coverUrl': coverUrl,
        'price': price,
        'quantity': quantity,
      };
}

class OrderModel {
  final String id;
  final String userId;
  final List<OrderItem> items;
  final double total;
  final String status; // placed, processing, shipped, delivered
  final String address;
  final String phone;
  final DateTime createdAt;

  OrderModel({
    required this.id,
    required this.userId,
    required this.items,
    required this.total,
    required this.status,
    required this.address,
    required this.phone,
    required this.createdAt,
  });

  static const statuses = ['placed', 'processing', 'shipped', 'delivered'];

  factory OrderModel.fromMap(String id, Map<String, dynamic> m) => OrderModel(
        id: id,
        userId: m['userId'] ?? '',
        items: ((m['items'] ?? []) as List)
            .map((e) => OrderItem.fromMap(Map<String, dynamic>.from(e)))
            .toList(),
        total: (m['total'] ?? 0).toDouble(),
        status: m['status'] ?? 'placed',
        address: m['address'] ?? '',
        phone: m['phone'] ?? '',
        createdAt: (m['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      );
}