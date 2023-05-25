import 'package:flutter/material.dart';
import 'package:house_wallet/components/ui/collapsible_container.dart';
import 'package:house_wallet/data/firestore.dart';
import 'package:house_wallet/data/shopping/shopping_item.dart';

class ShoppingItemTile extends StatefulWidget {
  final FirestoreDocument<ShoppingItemRef> doc;

  ShoppingItemTile(this.doc) /*  : super(key: Key(doc.id)) */; //TODO uncomment

  @override
  State<ShoppingItemTile> createState() => _ShoppingItemTileState();
}

class _ShoppingItemTileState extends State<ShoppingItemTile> {
  bool _checked = false;

  @override
  Widget build(BuildContext context) {
    final shoppingItem = widget.doc.data;
    return ListTile(
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 4),
      horizontalTitleGap: 4,
      title: Stack(
        alignment: Alignment.centerLeft,
        children: [
          Text(shoppingItem.title),
          CollapsibleContainer(
            collapsed: !_checked,
            axis: Axis.horizontal,
            curve: Curves.easeInOut,
            child: Container(color: Colors.black, width: double.infinity, height: 1),
          )
        ],
      ),
      leading: Checkbox(
        value: _checked,
        activeColor: Colors.black,
        onChanged: (newValue) => setState(() => _checked = newValue!),
      ),
      trailing: IconButton(onPressed: () {}, icon: const Icon(Icons.delete)),
    );
  }
}
