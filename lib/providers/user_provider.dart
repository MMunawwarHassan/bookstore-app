import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/user_service.dart';
import 'auth_provider.dart';

final userServiceProvider = Provider((ref) => UserService());

final userProfileProvider = StreamProvider<Map<String, dynamic>?>((ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return Stream.value(null);
  return ref.watch(userServiceProvider).watchProfile(user.uid);
});