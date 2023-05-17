import 'package:firebase_auth/firebase_auth.dart';

class LoggedUser {
  static User? get user => FirebaseAuth.instance.currentUser;
  static String? get uid => FirebaseAuth.instance.currentUser?.uid;

  //TODO list? get from firestore
  static String get houseId => "v7V77Vg85ttTbb9o7eHT";
}
