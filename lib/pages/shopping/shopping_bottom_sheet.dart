import 'package:flutter/material.dart';
import 'package:house_wallet/components/shopping/details_item_chip.dart';
import 'package:house_wallet/components/ui/collapsible_container.dart';
import 'package:house_wallet/components/ui/custom_bottom_sheet.dart';
import 'package:house_wallet/data/shopping/shopping_item.dart';
import 'package:house_wallet/main.dart';

class ShoppingBottomSheet extends StatefulWidget {
  const ShoppingBottomSheet({super.key});

  @override
  State<ShoppingBottomSheet> createState() => _ShoppingBottomSheetState();
}

class _ShoppingBottomSheetState extends State<ShoppingBottomSheet> {
  bool _detailsCollapsed = true;
  ShoppingItem _shoppingItem = const ShoppingItem(price: null, quantity: null, supermarket: null, title: "", to: {});

  String? _peopleLabel() {
    //TODO
    if (_shoppingItem.to.isEmpty) return null;

    return "TODO";
  }

  String? _priceQuantityLabel() {
    if (_shoppingItem.quantity == null && _shoppingItem.price == null) return null;

    String label = "";
    if (_shoppingItem.quantity != null) {
      label += "${_shoppingItem.quantity}x ";
    }
    if (_shoppingItem.price != null) {
      label += currencyFormat(context).format(_shoppingItem.price);
    }
    return label.trim();
  }

  @override
  Widget build(BuildContext context) {
    return CustomBottomSheet(
      padding: const EdgeInsets.all(8),
      spacing: 0,
      decoration: const BoxDecoration(
        color: Color(0xFFE6D676), //TODO theme
        boxShadow: [
          BoxShadow(blurRadius: 4),
        ],
      ),
      body: [
        Row(
          children: [
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.add),
                  hintText: localizations(context).addNewInput,
                  border: InputBorder.none,
                ),
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
              children: [
                DetailsItemChip(
                  icon: Icons.groups,
                  tooltip: localizations(context).peopleChipTooltip,
                  label: _peopleLabel(),
                  onTap: () {
                    final to = Map<String, int>.from(_shoppingItem.to);
                    to["a"] = 10;
                    setState(() => _shoppingItem = _shoppingItem.copyWith(to: to));
                  },
                ),
                DetailsItemChip(
                  icon: Icons.shopping_basket,
                  tooltip: localizations(context).supermarketChipTooltip,
                  label: _shoppingItem.supermarket,
                  onTap: () {
                    setState(() => _shoppingItem = _shoppingItem.copyWith(supermarket: "Test"));
                  },
                ),
                DetailsItemChip(
                  icon: Icons.attach_money,
                  tooltip: localizations(context).priceQuantityChipTooltip,
                  label: _priceQuantityLabel(),
                  onTap: () {
                    setState(() => _shoppingItem = _shoppingItem.copyWith(price: 10));
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
