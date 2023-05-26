import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String uid;
  final String username;
  final String? imageUrl;
  final String? iban;
  final String? payPal;

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

  factory User.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc, [SnapshotOptions? _]) {
    final data = doc.data()!;
    return User(
      uid: doc.id,
      username: data["username"],
      imageUrl: data["imageUrl"],
      iban: data["iban"],
      payPal: data["payPal"],
    );
  }

  static Map<String, dynamic> toFirestore(User user, [SetOptions? _]) {
    return {
      "username": user.username,
      "imageUrl": user.imageUrl,
      "iban": user.iban,
      "payPal": user.payPal,
    };
  }
}
