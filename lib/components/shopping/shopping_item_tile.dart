import 'package:flutter/material.dart';
import 'package:flutter_series/flutter_series.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:house_wallet/components/ui/collapsible_container.dart';
import 'package:house_wallet/data/firestore.dart';
import 'package:house_wallet/data/house_data.dart';
import 'package:house_wallet/data/shopping/shopping_item.dart';
import 'package:house_wallet/pages/shopping/shopping_item_details_bottom_sheet.dart';

class ShoppingItemTile extends StatelessWidget {
  final FirestoreDocument<ShoppingItemRef> shoppingItem;
  final bool checked;
  final void Function(bool value) setChecked;

  ShoppingItemTile(
    this.shoppingItem, {
    required this.checked,
    required this.setChecked,
  }) : super(key: Key(shoppingItem.id));

  static Widget shimmer({required double titleWidth}) {
    return PadRow(
      crossAxisAlignment: CrossAxisAlignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      children: [
        const Checkbox(value: false, onChanged: null),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(height: 14, width: titleWidth, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  void _openShoppingItemDetails(BuildContext context) {
    final house = HouseDataRef.of(context, listen: false);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      enableDrag: false,
      builder: (context) => ShoppingItemDetailsBottomSheet(shoppingItem, house: house),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Slidable(
      key: Key(shoppingItem.id),
      endActionPane: ActionPane(
        extentRatio: .2,
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            onPressed: (context) => shoppingItem.reference.delete(),
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            icon: Icons.delete,
          ),
        ],
      ),
      child: ListTile(
        dense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 4),
        horizontalTitleGap: 4,
        title: Padding(
          padding: const EdgeInsets.only(right: 16),
          child: Stack(
            alignment: Alignment.centerLeft,
            children: [
              Text(shoppingItem.data.title),
              CollapsibleContainer(
                collapsed: !checked,
                axis: Axis.horizontal,
                curve: Curves.easeInOut,
                child: Container(color: Colors.black, width: double.infinity, height: 1),
              )
            ],
          ),
        ),
        leading: Checkbox(
          value: checked,
          activeColor: Colors.black,
          onChanged: (value) => setChecked(value!),
        ),
        onTap: () => _openShoppingItemDetails(context),
      ),
    );
  }
}
