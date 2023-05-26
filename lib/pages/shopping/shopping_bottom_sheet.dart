import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:house_wallet/components/shopping/details_item_chip.dart';
import 'package:house_wallet/components/ui/collapsible_container.dart';
import 'package:house_wallet/components/ui/custom_bottom_sheet.dart';
import 'package:house_wallet/data/house_data.dart';
import 'package:house_wallet/data/logged_user.dart';
import 'package:house_wallet/data/shopping/shopping_item.dart';
import 'package:house_wallet/main.dart';
import 'package:house_wallet/pages/shopping/people_dialog.dart';
import 'package:house_wallet/pages/shopping/price_quantity_dialog.dart';
import 'package:house_wallet/pages/shopping/shopping_page.dart';
import 'package:house_wallet/pages/shopping/supermarket_dialog.dart';
import 'package:provider/provider.dart';

class ShoppingBottomSheet extends StatefulWidget {
  const ShoppingBottomSheet({super.key});

  @override
  State<ShoppingBottomSheet> createState() => _ShoppingBottomSheetState();
}

class _ShoppingBottomSheetState extends State<ShoppingBottomSheet> {
  final TextEditingController _titleController = TextEditingController();
  bool _detailsCollapsed = true;

  String? _titleValue;
  Map<String, int> _toValue = {};
  String? _supermarketValue;
  PriceQuantity? _priceQuantityValue;

  void _addShoppingItem() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    if ((_titleValue ?? "").isEmpty) return;

    try {
      await ShoppingPage.firestoreRef(Provider.of<LoggedUser>(context, listen: false).houseId).add(ShoppingItem(
        price: _priceQuantityValue?.price,
        quantity: _priceQuantityValue?.quantity,
        supermarket: _supermarketValue,
        title: _titleValue!,
        to: _toValue,
      ));

      FocusManager.instance.primaryFocus?.unfocus();
      _titleController.clear();
      setState(() {
        _detailsCollapsed = true;
        _titleValue = null;
        _toValue = {};
        _supermarketValue = null;
        _priceQuantityValue = null;
      });
    } on FirebaseException catch (e) {
      scaffoldMessenger.showSnackBar(SnackBar(content: Text("${localizations(context).saveChangesDialogContentError}\n(${e.message})")));
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
      decoration: const BoxDecoration(
        color: Color(0xFFE6D676), //TODO theme?
        boxShadow: [
          BoxShadow(blurRadius: 4),
        ],
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
                  hintText: localizations(context).addNewInput,
                  border: InputBorder.none,
                ),
                onEditingComplete: _addShoppingItem,
              ),
            ),
            IconButton(
              onPressed: () => setState(() => _detailsCollapsed = !_detailsCollapsed),
              icon: AnimatedRotation(
                turns: _detailsCollapsed ? .5 : 0,
                duration: const Duration(milliseconds: 200),
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
                  tooltip: localizations(context).peopleChipTooltip,
                  label: _toValue.isEmpty ? null : localizations(context).peopleChipLabel(_toValue.length),
                  onTap: () async {
                    final to = await showDialog<Map<String, int>>(context: context, builder: (_) => PeopleDialog(house: Provider.of<HouseDataRef>(context), initialValues: _toValue));
                    if (to == null) return;
                    setState(() => _toValue = to);
                  },
                ),
                DetailsItemChip(
                  icon: Icons.shopping_basket,
                  tooltip: localizations(context).supermarketChipTooltip,
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
