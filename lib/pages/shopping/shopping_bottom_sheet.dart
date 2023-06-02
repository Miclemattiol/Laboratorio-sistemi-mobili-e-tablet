import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:house_wallet/components/shopping/details_item_chip.dart';
import 'package:house_wallet/components/ui/collapsible_container.dart';
import 'package:house_wallet/components/ui/custom_bottom_sheet.dart';
import 'package:house_wallet/components/ui/custom_dialog.dart';
import 'package:house_wallet/data/house_data.dart';
import 'package:house_wallet/data/shopping/shopping_item.dart';
import 'package:house_wallet/main.dart';
import 'package:house_wallet/pages/shopping/people_share_dialog.dart';
import 'package:house_wallet/pages/shopping/price_quantity_dialog.dart';
import 'package:house_wallet/pages/shopping/shopping_page.dart';
import 'package:house_wallet/pages/shopping/supermarket_dialog.dart';
import 'package:house_wallet/themes.dart';

class ShoppingBottomSheet extends StatefulWidget {
  const ShoppingBottomSheet({super.key});

  @override
  State<ShoppingBottomSheet> createState() => _ShoppingBottomSheetState();
}

class _ShoppingBottomSheetState extends State<ShoppingBottomSheet> {
  late final _users = HouseDataRef.of(context).users;
  final TextEditingController _titleController = TextEditingController();
  bool _detailsCollapsed = true;

  String? _titleValue;
  late Map<String, int> _toValue = _users.map((key, value) => MapEntry(key, 1));
  String? _supermarketValue;
  PriceQuantity? _priceQuantityValue;

  void _addShoppingItem() async {
    if ((_titleValue ?? "").isEmpty) return;

    try {
      await ShoppingPage.firestoreRef(HouseDataRef.of(context, listen: false).id).add(ShoppingItem(
        price: _priceQuantityValue?.price,
        quantity: _priceQuantityValue?.quantity,
        supermarket: _supermarketValue,
        title: _titleValue!,
        to: _toValue,
      ));

      _titleController.clear();
      setState(() {
        _titleValue = null;
        _toValue = _users.map((key, value) => MapEntry(key, 1));
        _supermarketValue = null;
        _priceQuantityValue = null;
      });
    } on FirebaseException catch (error) {
      if (!context.mounted) return;
      CustomDialog.alert(
        context: context,
        title: localizations(context).error,
        content: "${localizations(context).saveChangesDialogContentError} (${error.message})",
      );
    }
  }

  String? _priceQuantityLabel() {
    if (_priceQuantityValue?.quantity == null && _priceQuantityValue?.price == null) return null;

    String label = "";
    if (_priceQuantityValue!.quantity != null) {
      label += "x${_priceQuantityValue!.quantity}";
    }
    if (_priceQuantityValue!.price != null) {
      if (label.isNotEmpty) label += "  •  ";
      label += currencyFormat(context).format(_priceQuantityValue!.price);
    }
    return label.trim();
  }

  @override
  Widget build(BuildContext context) {
    return CustomBottomSheet(
      padding: const EdgeInsets.all(8),
      spacing: 0,
      decoration: BoxDecoration(
        color: ShoppingPageStyle.of(context).shoppingPostItColor,
        boxShadow: const [BoxShadow(blurRadius: 4)],
      ),
      body: [
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _titleController,
                onChanged: (value) => _titleValue = value,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.add),
                  hintText: localizations(context).shoppingPageNew,
                  border: InputBorder.none,
                ),
                onEditingComplete: _addShoppingItem,
              ),
            ),
            IconButton(
              onPressed: () => setState(() => _detailsCollapsed = !_detailsCollapsed),
              icon: AnimatedRotation(
                turns: _detailsCollapsed ? .5 : 0,
                duration: animationDuration,
                child: const Icon(Icons.keyboard_arrow_down),
              ),
              tooltip: _detailsCollapsed ? localizations(context).showDetailsTooltip : localizations(context).hideDetailsTooltip,
            )
          ],
        ),
        CollapsibleContainer(
          collapsed: _detailsCollapsed,
          child: Padding(
            padding: const EdgeInsets.only(top: 16, bottom: 8),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                DetailsItemChip(
                  icon: Icons.groups,
                  tooltip: localizations(context).peopleShares,
                  label: _toValue.isEmpty
                      ? null
                      : _toValue.length == _users.length
                          ? localizations(context).peopleChipLabelEveryone
                          : localizations(context).peopleChipLabel(_toValue.length),
                  onTap: () async {
                    final house = HouseDataRef.of(context, listen: false);
                    final to = await showDialog<Map<String, int>>(context: context, builder: (_) => PeopleSharesDialog(house: house, initialValues: _toValue));
                    if (to == null) return;
                    setState(() => _toValue = to);
                  },
                ),
                DetailsItemChip(
                  icon: Icons.shopping_basket,
                  tooltip: localizations(context).supermarket,
                  label: _supermarketValue,
                  onTap: () async {
                    final supermarket = await showDialog<String>(context: context, builder: (context) => SupermarketDialog(initialValue: _supermarketValue));
                    if (supermarket == null) return;
                    setState(() => _supermarketValue = supermarket.isEmpty ? null : supermarket);
                  },
                ),
                DetailsItemChip(
                  icon: Icons.attach_money,
                  tooltip: localizations(context).priceQuantityChipTooltip,
                  label: _priceQuantityLabel(),
                  onTap: () async {
                    final priceQuantity = await showDialog<PriceQuantity>(context: context, builder: (context) => PriceQuantityDialog(initialValue: _priceQuantityValue));
                    if (priceQuantity == null) return;
                    setState(() => _priceQuantityValue = (priceQuantity.price == null && priceQuantity.quantity == null) ? null : priceQuantity);
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
