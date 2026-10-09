import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/wishlist_service.dart';
import 'auth_provider.dart';

final wishlistServiceProvider = Provider((ref) => WishlistService());

final wishlistIdsProvider = StreamProvider<Set<String>>((ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return Stream.value(<String>{});
  return ref.watch(wishlistServiceProvider).watchIds(user.uid);
});