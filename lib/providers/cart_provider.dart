import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/book_model.dart';
import '../models/cart_item_model.dart';

class CartNotifier extends Notifier<List<CartItem>> {
  @override
  List<CartItem> build() => [];

  void add(Book book) {
    final i = state.indexWhere((c) => c.book.id == book.id);
    if (i == -1) {
      state = [...state, CartItem(book: book)];
    } else {
      increase(book.id);
    }
  }

  void increase(String bookId) {
    state = [
      for (final c in state)
        if (c.book.id == bookId)
          CartItem(book: c.book, quantity: c.quantity + 1)
        else
          c
    ];
  }

  void decrease(String bookId) {
    state = [
      for (final c in state)
        if (c.book.id == bookId)
          CartItem(book: c.book, quantity: c.quantity - 1)
        else
          c
    ].where((c) => c.quantity > 0).toList();
  }

  void remove(String bookId) =>
      state = state.where((c) => c.book.id != bookId).toList();

  void clear() => state = [];
}

final cartProvider =
    NotifierProvider<CartNotifier, List<CartItem>>(CartNotifier.new);

final cartTotalProvider = Provider<double>(
    (ref) => ref.watch(cartProvider).fold(0.0, (s, c) => s + c.total));

final cartCountProvider = Provider<int>(
    (ref) => ref.watch(cartProvider).fold(0, (s, c) => s + c.quantity));