import 'package:cloud_firestore/cloud_firestore.dart';

class ShoppingItem {
  final num number;

  const ShoppingItem({
    required this.number,
  });

  factory ShoppingItem.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc, [SnapshotOptions? _]) {
    final data = doc.data()!;
    return ShoppingItem(
      number: data["number"],
    );
  }

  static Map<String, dynamic> toFirestore(ShoppingItem shoppingItem, [SetOptions? _]) {
    return {
      "number": shoppingItem.number,
    };
  }
}
