import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String uid;
  final String username;
  final String? imageUrl;
  final String? iban;
  final String? payPal;

  static const usernameKey = "username";
  static const imageUrlKey = "imageUrl";
  static const ibanKey = "iban";
  static const payPalKey = "payPal";

  const User({
    required this.uid,
    required this.username,
    required this.imageUrl,
    required this.iban,
    required this.payPal,
  });

  const User.invalid()
      : uid = "",
        username = "Invalid User",
        iban = null,
        imageUrl = null,
        payPal = null;

  bool get isInvalid => uid.isEmpty;

  factory User.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc, [SnapshotOptions? _]) {
    final data = doc.data()!;
    return User(
      uid: doc.id,
      username: data[usernameKey],
      imageUrl: data[imageUrlKey],
      iban: data[ibanKey],
      payPal: data[payPalKey],
    );
  }

  static Map<String, dynamic> toFirestore(User user, [SetOptions? _]) {
    return {
      usernameKey: user.username,
      imageUrlKey: user.imageUrl,
      ibanKey: user.iban,
      payPalKey: user.payPal,
    };
  }
}
