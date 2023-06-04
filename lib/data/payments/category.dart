import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:house_wallet/data/firestore.dart';
import 'package:house_wallet/data/icons.dart';

typedef Categories = List<FirestoreDocument<Category>>;

class Category {
  final String iconName;
  final String name;

  static const iconKey = "icon";
  static const nameKey = "name";

  const Category({
    required this.iconName,
    required this.name,
  });

  IconData get icon => icons[iconName] ?? Icons.shopping_cart;

  factory Category.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc, [SnapshotOptions? _]) {
    final data = doc.data()!;
    return Category(
      iconName: data[iconKey],
      name: data[nameKey],
    );
  }

  static Map<String, dynamic> toFirestore(Category category, [SetOptions? _]) {
    return {
      iconKey: category.iconName,
      nameKey: category.name,
    };
  }
}
