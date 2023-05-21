import 'package:flutter/material.dart';
import 'package:house_wallet/data/firestore.dart';
import 'package:house_wallet/data/shopping/shopping_item.dart';

class ShoppingItemTile extends StatelessWidget {
  final FirestoreDocument<ShoppingItem> doc;

  ShoppingItemTile(this.doc) : super(key: Key(doc.id));

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text("${doc.data.number}"),
      subtitle: Text(doc.id),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.plus_one),
            splashRadius: 24,
            onPressed: () {
              doc.reference.update({
                "number": doc.data.number + 1
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            splashRadius: 24,
            onPressed: doc.reference.delete,
          ),
        ],
      ),
    );
  }
}
