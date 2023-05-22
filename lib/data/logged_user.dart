import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoggedUser {
  static User? get user => FirebaseAuth.instance.currentUser;
  static String? get uid => FirebaseAuth.instance.currentUser?.uid;
  static String get houseId => _houses[currentHouse];

  //TODO multiple houses?
  static int currentHouse = 0;
  static List<String> _houses = [];

  static Future<void> updateData() async {
    if (uid == null) return;

    final data = await FirebaseFirestore.instance.collection("/groups").where("users", arrayContains: LoggedUser.uid!).get();
    _houses = data.docs.map((doc) => doc.id).toList();
  }
}
