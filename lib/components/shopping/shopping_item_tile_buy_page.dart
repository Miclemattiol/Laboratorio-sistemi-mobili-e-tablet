import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_series/flutter_series.dart';
import 'package:house_wallet/components/form/number_form_field.dart';
import 'package:house_wallet/components/shopping/details_item_chip.dart';
import 'package:house_wallet/components/ui/collapsible_container.dart';
import 'package:house_wallet/components/ui/custom_dialog.dart';
import 'package:house_wallet/data/firestore.dart';
import 'package:house_wallet/data/house_data.dart';
import 'package:house_wallet/data/shopping/shopping_item.dart';
import 'package:house_wallet/data/user.dart';
import 'package:house_wallet/main.dart';
import 'package:house_wallet/pages/shopping/people_share_dialog.dart';
import 'package:house_wallet/themes.dart';
import 'package:house_wallet/utils.dart';

class ShoppingItemTileBuyPage extends StatefulWidget {
  final FirestoreDocument<ShoppingItemRef> doc;
  final num? value;
  final void Function(num value) onChanged;
  final void Function(Shares shares) onSharesChanged;
  final void Function()? onRemoved;

  final HouseDataRef house;
  late final Map<String, User> users;
  // Shares _toValue = _users.map((key, value) => MapEntry(key, 1));
  final Shares toValue;

  ShoppingItemTileBuyPage(
    this.doc, {
    required this.value,
    required this.onChanged,
    required this.onSharesChanged,
    required this.house,
    required this.toValue,
    this.onRemoved,
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
  late Shares toValue = widget.toValue;
  bool _collapsed = true;

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
    return Column(
      children: [
        ListTile(
          title: Text(shoppingItem.title),
          trailing: PadRow(
            mainAxisSize: MainAxisSize.min,
            spacing: 8,
            children: [
              // DetailsItemChip(
              //   icon: Icons.attach_money,
              //   tooltip: localizations(context).priceAndQuantity,
              //   label: widget.value != null ? currencyFormat(context).format(widget.value) : null,
              //   onTap: () async {
              //     final price = await showDialog<num>(context: context, builder: (context) => PriceQuantityDialog(initialValue: widget.value));
              //     if (price == null) return;
              //     _saveShoppingItemPrice(price);
              //     widget.onChanged(price);
              //   },
              // ),
              SizedBox(
                width: 96,
                child: NumberFormField(
                  initialValue: widget.value,
                  decoration: inputDecoration(localizations(context).price, true),
                  decimal: true,
                  onChanged: (price) => setState(() {
                    if (price == null) return;
                    _saveShoppingItemPrice(price);
                    widget.onChanged(price);
                  }),
                  validator: (price) => (price == null) ? localizations(context).priceMissing : null,
                ),
              ),
              IconButton(icon: Icon(_collapsed ? Icons.expand_more : Icons.expand_less), onPressed: () => setState(() => _collapsed = !_collapsed)),
            ],
          ),
        ),
        CollapsibleContainer(
          collapsed: _collapsed,
          child: PadRow(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            spacing: 8,
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.center,
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
                  setState(() => toValue = to);
                  widget.onSharesChanged(to);
                },
              ),
              IconButton(onPressed: widget.onRemoved, icon: const Icon(Icons.delete))
            ],
          ),
        ),
      ],
    );
  }
}
