import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Category {
  final IconData icon;
  final String name;

  static const iconKey = "icon";
  static const nameKey = "name";

  const Category({
    required this.icon,
    required this.name,
  });

  factory Category.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc, [SnapshotOptions? _]) {
    final data = doc.data()!;
    return Category(
      icon: IconData(data[iconKey], fontFamily: "MaterialIcons"),
      name: data[nameKey],
    );
  }

  static Map<String, dynamic> toFirestore(Category category, [SetOptions? _]) {
    return {
      iconKey: category.icon.codePoint,
      nameKey: category.name,
    };
  }
}
