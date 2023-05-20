import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String username;
  final String? imageUrl;
  final String? iban;
  final String? payPal;

  const User({
    required this.username,
    required this.imageUrl,
    required this.iban,
    required this.payPal,
  });

  factory User.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc, [SnapshotOptions? _]) {
    final data = doc.data()!;
    return User(
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
