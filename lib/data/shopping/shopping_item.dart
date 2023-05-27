import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:house_wallet/data/firestore.dart';
import 'package:house_wallet/data/house_data.dart';
import 'package:house_wallet/data/user_share.dart';

class ShoppingItem {
  final num? price;
  final int? quantity;
  final String? supermarket;
  final String title;
  final Map<String, int> to;

  const ShoppingItem({
    required this.price,
    required this.quantity,
    required this.supermarket,
    required this.title,
    required this.to,
  });

  factory ShoppingItem.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc, [SnapshotOptions? _]) {
    final data = doc.data()!;
    return ShoppingItem(
      price: data["price"],
      quantity: data["quantity"],
      supermarket: data["supermarket"],
      title: data["title"],
      to: Map.from(data["to"]),
    );
  }

  static Map<String, dynamic> toFirestore(ShoppingItem shoppingItem, [SetOptions? _]) {
    return {
      "price": shoppingItem.price,
      "quantity": shoppingItem.quantity,
      "supermarket": shoppingItem.supermarket,
      "title": shoppingItem.title,
      "to": shoppingItem.to,
    };
  }
}

class ShoppingItemRef {
  final num? price;
  final int? quantity;
  final String? supermarket;
  final String title;
  final Map<String, UserShare> to;

  const ShoppingItemRef({
    required this.price,
    required this.quantity,
    required this.supermarket,
    required this.title,
    required this.to,
  });

  static FirestoreConverter<ShoppingItem, ShoppingItemRef> converter(BuildContext context) {
    final houseRef = HouseDataRef.of(context);
    return firestoreConverter((doc) {
      final shoppingItem = doc.data();
      return ShoppingItemRef(
        price: shoppingItem.price,
        quantity: shoppingItem.quantity,
        supermarket: shoppingItem.supermarket,
        title: shoppingItem.title,
        to: shoppingItem.to.map((uid, share) => MapEntry(uid, UserShare(houseRef.getUser(uid), share))),
      );
    });
  }
}
