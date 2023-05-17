import 'package:cloud_firestore/cloud_firestore.dart';

class ShoppingItem {
  final num number;

  const ShoppingItem({
    required this.number,
  });

  factory ShoppingItem.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc, [SnapshotOptions? _]) {
    return ShoppingItem(number: doc.data()?["number"]);
  }

  static Map<String, dynamic> toFirestore(ShoppingItem shoppingItem, [SetOptions? _]) {
    return {
      "number": shoppingItem.number,
    };
  }
}