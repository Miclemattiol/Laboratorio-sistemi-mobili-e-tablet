import 'package:flutter/material.dart';
import 'package:house_wallet/data/firestore.dart';
import 'package:house_wallet/data/shopping/shopping_item.dart';

class ShoppingItemTile extends StatelessWidget {
  final FirestoreDocument<ShoppingItemRef> doc;

  ShoppingItemTile(this.doc) : super(key: Key(doc.id));

  @override
  Widget build(BuildContext context) {
    final shoppingItem = doc.data;
    return ListTile(
      title: Text("price: ${shoppingItem.price} quantity: ${shoppingItem.quantity} supermarket: '${shoppingItem.supermarket}' title: '${shoppingItem.title}' to: ${shoppingItem.to.length}"),
    );
  }
}
