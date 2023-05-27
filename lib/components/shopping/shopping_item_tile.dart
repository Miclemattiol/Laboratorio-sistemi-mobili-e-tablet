import 'package:flutter/material.dart';
import 'package:house_wallet/components/ui/collapsible_container.dart';
import 'package:house_wallet/data/firestore.dart';
import 'package:house_wallet/data/house_data.dart';
import 'package:house_wallet/data/shopping/shopping_item.dart';
import 'package:house_wallet/main.dart';
import 'package:house_wallet/pages/shopping/shopping_item_details_bottom_sheet.dart';

class ShoppingItemTile extends StatefulWidget {
  final FirestoreDocument<ShoppingItemRef> shoppingItem;

  ShoppingItemTile(this.shoppingItem) : super(key: Key(shoppingItem.id));

  @override
  State<ShoppingItemTile> createState() => _ShoppingItemTileState();
}

class _ShoppingItemTileState extends State<ShoppingItemTile> {
  bool _checked = false;

  void _openShoppingItemDetails(BuildContext context) {
    final house = HouseDataRef.of(context, listen: false);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      enableDrag: false,
      builder: (context) => ShoppingItemDetailsBottomSheet(widget.shoppingItem, house: house),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 4),
      horizontalTitleGap: 4,
      title: Stack(
        alignment: Alignment.centerLeft,
        children: [
          Text(widget.shoppingItem.data.title),
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
      trailing: IconButton(
        tooltip: localizations(context).delete,
        onPressed: () => widget.shoppingItem.reference.delete(),
        icon: const Icon(Icons.delete),
      ),
      onTap: () => _openShoppingItemDetails(context),
    );
  }
}
