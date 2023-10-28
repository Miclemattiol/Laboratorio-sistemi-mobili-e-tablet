import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_series/flutter_series.dart';
import 'package:house_wallet/components/shopping/details_item_chip.dart';
import 'package:house_wallet/components/ui/custom_dialog.dart';
import 'package:house_wallet/data/firestore.dart';
import 'package:house_wallet/data/house_data.dart';
import 'package:house_wallet/data/shopping/shopping_item.dart';
import 'package:house_wallet/data/user.dart';
import 'package:house_wallet/main.dart';
import 'package:house_wallet/pages/shopping/people_share_dialog.dart';
import 'package:house_wallet/pages/shopping/price_quantity_dialog.dart';
import 'package:house_wallet/utils.dart';

class ShoppingItemTileBuyPage extends StatefulWidget {
  final FirestoreDocument<ShoppingItemRef> doc;
  final num? value;
  final void Function(num value) onChanged;
  final void Function(Shares shares) onSharesChanged;

  final HouseDataRef house;
  late final Map<String, User> users;
  // Shares _toValue = _users.map((key, value) => MapEntry(key, 1));
  Shares toValue;

  ShoppingItemTileBuyPage(
    this.doc, {
    required this.value,
    required this.onChanged,
    required this.onSharesChanged,
    required this.house,
    required this.toValue,
    super.key,
  }) {
    users = house.users;
  }

  @override
  State<ShoppingItemTileBuyPage> createState() => _ShoppingItemTileBuyPageState();
}

class _ShoppingItemTileBuyPageState extends State<ShoppingItemTileBuyPage> {
  // late final _users = HouseDataRef.of(context).users;
  // late final house = HouseDataRef.of(context, listen: false);
  // late Shares _toValue = _users.map((key, value) => MapEntry(key, 1));

  void _saveShoppingItemPrice(num price) async {
    try {
      if (await isNotConnectedToInternet(context) || !mounted) return;

      await widget.doc.reference.update({
        ShoppingItem.priceKey: price,
      });
    } on FirebaseException catch (error) {
      if (!context.mounted) return;
      CustomDialog.alert(
        context: context,
        title: localizations(context).error,
        content: localizations(context).saveChangesError(error.message.toString()),
      );
    }
  }

  void _saveShoppingItemShares(Shares shares) async {
    try {
      if (await isNotConnectedToInternet(context) || !mounted) return;

      await widget.doc.reference.update({
        ShoppingItem.toKey: shares,
      });
    } on FirebaseException catch (error) {
      if (!context.mounted) return;
      CustomDialog.alert(
        context: context,
        title: localizations(context).error,
        content: localizations(context).saveChangesError(error.message.toString()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final shoppingItem = widget.doc.data;
    return ListTile(
      title: Text(shoppingItem.title),
      trailing: PadRow(
        mainAxisSize: MainAxisSize.min,
        spacing: 8,
        children: [
          DetailsItemChip(
            icon: Icons.groups,
            tooltip: localizations(context).peopleShares,
            label: widget.toValue.isEmpty
                ? null
                : widget.toValue.length == widget.users.length
                    ? localizations(context).peopleChipLabelEveryone
                    : localizations(context).peopleChipLabel(widget.toValue.length),
            onTap: () async {
              final to = await showDialog<Shares>(context: context, builder: (_) => PeopleSharesDialog(house: widget.house, initialValues: widget.toValue));
              if (to == null) return;
              _saveShoppingItemShares(to);
              setState(() => widget.toValue = to);
              widget.onSharesChanged(to);
            },
          ),
          DetailsItemChip(
            icon: Icons.attach_money,
            tooltip: localizations(context).priceAndQuantity,
            label: widget.value != null ? currencyFormat(context).format(widget.value) : null,
            onTap: () async {
              final price = await showDialog<num>(context: context, builder: (context) => PriceQuantityDialog(initialValue: widget.value));
              if (price == null) return;
              _saveShoppingItemPrice(price);
              widget.onChanged(price);
            },
          ),
        ],
      ),
    );
  }
}
