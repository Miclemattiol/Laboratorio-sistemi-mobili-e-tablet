import 'package:flutter/material.dart';
import 'package:house_wallet/components/ui/collapsible_container.dart';
import 'package:house_wallet/components/ui/custom_bottom_sheet.dart';
import 'package:house_wallet/main.dart';

class ShoppingBottomSheet extends StatefulWidget {
  const ShoppingBottomSheet({super.key});

  @override
  State<ShoppingBottomSheet> createState() => _ShoppingBottomSheetState();
}

class _ShoppingBottomSheetState extends State<ShoppingBottomSheet> {
  bool _detailsCollapsed = true;

  @override
  Widget build(BuildContext context) {
    return CustomBottomSheet(
      padding: const EdgeInsets.all(8),
      spacing: 0,
      backgroundColor: const Color(0xFFE6D676),
      body: [
        Row(
          children: [
            const Expanded(
              child: TextField(
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.add),
                  hintText: "Aggiungi nuovo...",
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
          child: const Padding(
            padding: EdgeInsets.only(top: 8),
            child: Wrap(
              spacing: 8,
              children: [
                Chip(label: Text("asd"), avatar: Icon(Icons.abc)),
                Chip(label: Text("asd"), avatar: Icon(Icons.abc)),
                Chip(label: Text("asd"), avatar: Icon(Icons.abc)),
                Chip(label: Text("asd"), avatar: Icon(Icons.abc)),
                Chip(label: Text("asd"), avatar: Icon(Icons.abc)),
                Chip(label: Text("asd"), avatar: Icon(Icons.abc)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
