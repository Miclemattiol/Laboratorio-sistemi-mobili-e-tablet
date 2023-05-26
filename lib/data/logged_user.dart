import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoggedUser {
  static User? get user => FirebaseAuth.instance.currentUser;
  static String? get uid => FirebaseAuth.instance.currentUser?.uid;
  static String? get houseId => _houses.isNotEmpty ? _houses.first : null;

  //TODO multiple houses?
  static List<String> _houses = [];

  static Future<void> updateData() async {
    if (uid == null) return;

    final data = await FirebaseFirestore.instance.collection("/groups").where("users", arrayContains: LoggedUser.uid!).get();
    _houses = data.docs.map((doc) => doc.id).toList();
    print(_houses);
    
  }
}
