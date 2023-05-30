import 'package:cloud_firestore/cloud_firestore.dart';

class RecipeItem {
  final String title;
  final num? price;
  final int? quantity;
  final String? supermarket;

  static const titleKey = "title";
  static const priceKey = "price";
  static const quantityKey = "quantity";
  static const supermarketKey = "supermarket";

  const RecipeItem({
    required this.title,
    this.price,
    this.quantity,
    this.supermarket,
  });

  factory RecipeItem.fromJson(Map<String, dynamic> json) {
    return RecipeItem(
      title: json[titleKey],
      price: json[priceKey],
      quantity: json[quantityKey],
      supermarket: json[supermarketKey],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      titleKey: title,
      priceKey: price,
      quantityKey: quantity,
      supermarketKey: supermarket,
    };
  }
}

class Recipe {
  final String title;
  final List<RecipeItem> items;

  static const titleKey = "title";
  static const itemsKey = "items";

  const Recipe({
    required this.title,
    required this.items,
  });

  factory Recipe.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc, [SnapshotOptions? _]) {
    final data = doc.data()!;
    return Recipe(
      title: data[titleKey],
      items: List.from(data[itemsKey]).map((json) => RecipeItem.fromJson(json)).toList(),
    );
  }

  static Map<String, dynamic> toFirestore(Recipe recipe, [SetOptions? _]) {
    return {
      titleKey: recipe.title,
      itemsKey: recipe.items.map((item) => item.toJson()),
    };
  }
}
