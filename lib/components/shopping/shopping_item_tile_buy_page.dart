import 'package:flutter/material.dart';
import 'package:house_wallet/components/form/number_form_field.dart';
import 'package:house_wallet/data/firestore.dart';
import 'package:house_wallet/data/shopping/shopping_item.dart';
import 'package:house_wallet/main.dart';
import 'package:house_wallet/themes.dart';

class ShoppingItemTileBuyPage extends StatelessWidget {
  final FirestoreDocument<ShoppingItemRef> doc;
  final void Function(num? value)? onChanged;

  const ShoppingItemTileBuyPage(
    this.doc, {
    required this.onChanged,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final shoppingItem = doc.data;
    return ListTile(
      title: Text(shoppingItem.title),
      trailing: ConstrainedBox(
        constraints: multiInputRowConstraints(context),
        child: NumberFormField(
          initialValue: shoppingItem.price,
          decoration: inputDecoration(localizations(context).price).copyWith(isDense: true),
          decimal: true,
          onChanged: onChanged,
        ),
      ),
    );
  }
}
