import 'package:flutter/material.dart';
import 'package:flutter_series/flutter_series.dart';
import 'package:house_wallet/data/shopping/recipe.dart';
import 'package:house_wallet/main.dart';

class RecipeItemListTile extends StatelessWidget {
  final RecipeItem? item;
  final void Function()? onPressed;
  final void Function()? onDelete;
  final bool enabled;

  const RecipeItemListTile(
    RecipeItem this.item, {
    required this.onPressed,
    required this.onDelete,
    this.enabled = true,
    super.key,
  });

  const RecipeItemListTile.createNew({
    required this.onPressed,
    this.enabled = true,
    super.key,
  })  : item = null,
        onDelete = null;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: enabled ? onPressed : null,
      child: PadRow(
        padding: const EdgeInsets.only(left: 4),
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Text(
              item == null ? localizations(context).recipesPageNewItem : item!.title,
              style: TextStyle(
                fontStyle: item == null ? FontStyle.italic : null,
                color: enabled ? null : Theme.of(context).disabledColor,
              ),
            ),
          ),
          IconButton(
            tooltip: item == null ? localizations(context).recipesPageNewItem : localizations(context).delete,
            constraints: const BoxConstraints(),
            style: const ButtonStyle(tapTargetSize: MaterialTapTargetSize.shrinkWrap),
            onPressed: enabled ? (item == null ? onPressed : onDelete) : null,
            icon: Icon(item == null ? Icons.add_circle : Icons.remove_circle),
          ),
        ],
      ),
    );
  }
}
