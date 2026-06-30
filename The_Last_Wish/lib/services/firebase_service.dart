import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  static Future<void> addWish(Map<String, dynamic> data) async {
    await _db.collection("wishes").add(data);
  }

  static Stream<QuerySnapshot> getWishes() {
    return _db
        .collection("wishes")
        .orderBy("time", descending: true)
        .snapshots();
  }

  static Future<void> deleteWish(String id) async {
    await _db.collection("wishes").doc(id).delete();
  }
}
