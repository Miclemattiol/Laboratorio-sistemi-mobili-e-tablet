import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_series/flutter_series.dart';
import 'package:house_wallet/components/ui/custom_bottom_sheet.dart';
import 'package:house_wallet/components/ui/custom_dialog.dart';
import 'package:house_wallet/data/house_data.dart';
import 'package:house_wallet/data/shopping/shopping_item.dart';
import 'package:house_wallet/main.dart';
import 'package:house_wallet/pages/shopping/price_quantity_dialog.dart';
import 'package:house_wallet/pages/shopping/shopping_page.dart';
import 'package:house_wallet/utils.dart';

class ShoppingBottomSheet extends StatefulWidget {
  const ShoppingBottomSheet({super.key});

  @override
  State<ShoppingBottomSheet> createState() => _ShoppingBottomSheetState();
}

class _ShoppingBottomSheetState extends State<ShoppingBottomSheet> {
  late final _users = HouseDataRef.of(context, listen: false).users;
  final TextEditingController _titleController = TextEditingController();

  String? _titleValue;
  late Shares _toValue = _users.map((key, value) => MapEntry(key, 1));
  String? _supermarketValue;
  PriceQuantity? _priceQuantityValue;

  void _addShoppingItem() async {
    if ((_titleValue ?? "").isEmpty) return;

    try {
      if (await isNotConnectedToInternet(context) || !context.mounted) return;

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
        content: localizations(context).saveChangesError(error.message.toString()),
      );
    }
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
        PadRow(
          padding: const EdgeInsets.only(left: 16),
          children: [
            Expanded(
              child: TextField(
                controller: _titleController,
                onChanged: (value) => setState(() => _titleValue = value),
                style: const TextStyle(color: Colors.black),
                decoration: InputDecoration(
                  suffixIcon: _titleController.text.isNotEmpty
                      ? GestureDetector(
                          onTap: _addShoppingItem,
                          child: const Icon(
                            Icons.add,
                            color: Colors.black,
                          ))
                      : null,
                  hintText: localizations(context).shoppingPageNew,
                  hintStyle: const TextStyle(color: Colors.black, fontWeight: FontWeight.normal),
                  border: InputBorder.none,
                ),
                onEditingComplete: _addShoppingItem,
              ),
            ),
            // IconButton(
            //   onPressed: () => setState(() => _detailsCollapsed = !_detailsCollapsed),
            //   icon: AnimatedRotation(
            //     turns: _detailsCollapsed ? .5 : 0,
            //     duration: animationDuration,
            //     child: const Icon(Icons.keyboard_arrow_down),
            //   ),
            //   tooltip: _detailsCollapsed ? localizations(context).showDetailsTooltip : localizations(context).hideDetailsTooltip,
            // )
          ],
        ),
        // CollapsibleContainer(
        //   collapsed: _detailsCollapsed,
        //   child: Padding(
        //     padding: const EdgeInsets.only(top: 16, bottom: 8),
        //     child: Wrap(
        //       spacing: 8,
        //       runSpacing: 8,
        //       children: [
        //         DetailsItemChip(
        //           icon: Icons.groups,
        //           tooltip: localizations(context).peopleShares,
        //           label: _toValue.isEmpty
        //               ? null
        //               : _toValue.length == _users.length
        //                   ? localizations(context).peopleChipLabelEveryone
        //                   : localizations(context).peopleChipLabel(_toValue.length),
        //           onTap: () async {
        //             final house = HouseDataRef.of(context, listen: false);
        //             final to = await showDialog<Shares>(context: context, builder: (_) => PeopleSharesDialog(house: house, initialValues: _toValue));
        //             if (to == null) return;
        //             setState(() => _toValue = to);
        //           },
        //         ),
        //         DetailsItemChip(
        //           icon: Icons.attach_money,
        //           tooltip: localizations(context).priceAndQuantity,
        //           label: _priceQuantityValue?.label(context),
        //           onTap: () async {
        //             final priceQuantity = await showDialog<PriceQuantity>(context: context, builder: (context) => PriceQuantityDialog(initialValue: _priceQuantityValue));
        //             if (priceQuantity == null) return;
        //             setState(() => _priceQuantityValue = (priceQuantity.price == null && priceQuantity.quantity == null) ? null : priceQuantity);
        //           },
        //         ),
        //       ],
        //     ),
        //   ),
        // ),
      ],
    );
  }
}
