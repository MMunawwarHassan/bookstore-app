import 'package:cloud_firestore/cloud_firestore.dart';

class AdminService {
  final _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _books =>
      _db.collection('books');

  Future<void> addBook(Map<String, dynamic> data) => _books.add({
        ...data,
        'rating': 0.0,
        'ratingCount': 0,
        'popularity': 0,
        'createdAt': FieldValue.serverTimestamp(),
      });

  Future<void> updateBook(String id, Map<String, dynamic> data) =>
      _books.doc(id).update(data);

  Future<void> deleteBook(String id) => _books.doc(id).delete();

  Stream<List<Map<String, dynamic>>> watchUsers() =>
      _db.collection('users').snapshots().map((s) =>
          s.docs.map((d) => {...d.data(), 'uid': d.id}).toList());

  Future<void> setRole(String uid, String role) =>
      _db.collection('users').doc(uid).update({'role': role});
}