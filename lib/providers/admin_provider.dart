import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/order_model.dart';
import '../services/admin_service.dart';
import 'order_provider.dart';
import 'user_provider.dart';

final adminServiceProvider = Provider((ref) => AdminService());

final isAdminProvider = Provider<bool>((ref) {
  final profile = ref.watch(userProfileProvider).value;
  return profile?['role'] == 'admin';
});

final allOrdersProvider = StreamProvider<List<OrderModel>>(
    (ref) => ref.watch(orderServiceProvider).watchAllOrders());

final allUsersProvider = StreamProvider<List<Map<String, dynamic>>>(
    (ref) => ref.watch(adminServiceProvider).watchUsers());