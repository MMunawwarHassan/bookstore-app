import 'book_model.dart';

class CartItem {
  final Book book;
  final int quantity;
  CartItem({required this.book, this.quantity = 1});

  double get total => book.price * quantity;
}