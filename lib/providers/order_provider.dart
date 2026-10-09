import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/order_model.dart';
import '../services/order_service.dart';
import 'auth_provider.dart';

final orderServiceProvider = Provider((ref) => OrderService());

final userOrdersProvider = StreamProvider<List<OrderModel>>((ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return Stream.value([]);
  return ref.watch(orderServiceProvider).watchUserOrders(user.uid);
});