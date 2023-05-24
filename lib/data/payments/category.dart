import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Category {
  final IconData icon;
  final String name;

  const Category({
    required this.icon,
    required this.name,
  });

  factory Category.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc, [SnapshotOptions? _]) {
    final data = doc.data()!;
    return Category(
      icon: IconData(data["icon"], fontFamily: "MaterialIcons"),
      name: data["name"],
    );
  }

  static Map<String, dynamic> toFirestore(Category category, [SetOptions? _]) {
    return {
      "icon": category.icon.codePoint,
      "name": category.name,
    };
  }
}
