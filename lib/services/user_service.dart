import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserService {
  final _col = FirebaseFirestore.instance.collection('users');

  Stream<Map<String, dynamic>?> watchProfile(String uid) =>
      _col.doc(uid).snapshots().map((d) => d.data());

  Future<void> updateProfile({
    required String uid,
    required String name,
    required String phone,
    required String address,
    required String paymentMethod,
  }) async {
    await _col.doc(uid).set({
      'name': name,
      'phone': phone,
      'address': address,
      'paymentMethod': paymentMethod,
    }, SetOptions(merge: true));
    await FirebaseAuth.instance.currentUser?.updateDisplayName(name);
  }
}