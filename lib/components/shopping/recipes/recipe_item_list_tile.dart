import 'package:flutter/material.dart';
import 'package:flutter_series/flutter_series.dart';
import 'package:house_wallet/data/shopping/recipe.dart';
import 'package:house_wallet/main.dart';

class RecipeItemListTile extends StatelessWidget {
  final RecipeItem? item;
  final void Function() onPressed;
  final void Function()? onDelete;

  const RecipeItemListTile(
    RecipeItem this.item, {
    required this.onPressed,
    required void Function() this.onDelete,
    super.key,
  });

  const RecipeItemListTile.createNew({
    required this.onPressed,
    super.key,
  })  : item = null,
        onDelete = null;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: PadRow(
        padding: const EdgeInsets.only(left: 4),
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Text(item == null ? localizations(context).addNewInput : item!.title),
          ),
          IconButton(
            tooltip: item == null ? localizations(context).addNewInput : localizations(context).delete,
            constraints: const BoxConstraints(),
            style: const ButtonStyle(tapTargetSize: MaterialTapTargetSize.shrinkWrap),
            onPressed: item == null ? onPressed : onDelete,
            icon: Icon(item == null ? Icons.add_circle : Icons.remove_circle),
          ),
        ],
      ),
    );
  }
}
