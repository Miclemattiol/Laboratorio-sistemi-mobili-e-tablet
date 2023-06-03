import 'package:flutter/material.dart';
import 'package:house_wallet/components/shopping/details_item_chip.dart';
import 'package:house_wallet/data/firestore.dart';
import 'package:house_wallet/data/shopping/shopping_item.dart';
import 'package:house_wallet/main.dart';
import 'package:house_wallet/pages/shopping/price_quantity_dialog.dart';

class ShoppingItemTileBuyPage extends StatelessWidget {
  final FirestoreDocument<ShoppingItemRef> doc;
  final PriceQuantity value;
  final void Function(PriceQuantity value) onChanged;

  const ShoppingItemTileBuyPage(
    this.doc, {
    required this.value,
    required this.onChanged,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final shoppingItem = doc.data;
    return ListTile(
      title: Text(shoppingItem.title),
      trailing: DetailsItemChip(
        icon: Icons.attach_money,
        tooltip: localizations(context).priceAndQuantity,
        label: value.label(context),
        onTap: () async {
          final priceQuantity = await showDialog<PriceQuantity>(context: context, builder: (context) => PriceQuantityDialog(initialValue: value));
          if (priceQuantity == null) return;
          onChanged(priceQuantity);
        },
      ),
    );
  }
}
