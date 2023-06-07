import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_series/flutter_series.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:house_wallet/data/firestore.dart';
import 'package:house_wallet/data/house_data.dart';
import 'package:house_wallet/data/shopping/recipe.dart';
import 'package:house_wallet/data/shopping/shopping_item.dart';
import 'package:house_wallet/main.dart';
import 'package:house_wallet/pages/shopping/people_share_dialog.dart';
import 'package:house_wallet/pages/shopping/recipes/recipe_bottom_sheet.dart';
import 'package:house_wallet/pages/shopping/shopping_page.dart';
import 'package:house_wallet/utils.dart';

class RecipeListTile extends StatelessWidget {
  final FirestoreDocument<Recipe> recipe;
  final HouseDataRef house;

  RecipeListTile(
    this.recipe, {
    required this.house,
  }) : super(key: Key(recipe.id));

  static Widget shimmer({required double titleWidth}) {
    return PadRow(
      crossAxisAlignment: CrossAxisAlignment.center,
      padding: const EdgeInsets.symmetric(vertical: 21, horizontal: 16),
      children: [
        Container(height: 14, width: titleWidth, color: Colors.white),
      ],
    );
  }

  void _editRecipe(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      enableDrag: false,
      builder: (context) => RecipeBottomSheet.edit(recipe, house: house),
    );
  }

  void _addToShoppingList(BuildContext context) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final appLocalizations = localizations(context);

    if (await isNotConnectedToInternet(context) || !context.mounted) return;

    final to = await showDialog<Shares>(context: context, builder: (context) => PeopleSharesDialog(house: house, initialValues: house.users.map((key, value) => MapEntry(key, 1))));
    if (to == null) return;

    try {
      final batch = FirebaseFirestore.instance.batch();

      for (final item in recipe.data.items) {
        batch.set<ShoppingItem>(
          ShoppingPage.firestoreRef(house.id).doc(),
          ShoppingItem(
            price: item.price,
            quantity: item.quantity,
            supermarket: item.supermarket,
            title: item.title,
            to: to,
          ),
        );
      }
      await batch.commit();
      scaffoldMessenger.showSnackBar(SnackBar(content: Text(appLocalizations.addToShoppingListSuccess)));
    } on FirebaseException catch (error) {
      scaffoldMessenger.showSnackBar(SnackBar(content: Text("${appLocalizations.addToShoppingListError}\n(${error.message})")));
    }
  }

  void _delete(BuildContext context) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final appLocalizations = localizations(context);

    if (await isNotConnectedToInternet(context) || !context.mounted) return;

    try {
      await recipe.reference.delete();
    } on FirebaseException catch (error) {
      scaffoldMessenger.showSnackBar(SnackBar(content: Text(appLocalizations.actionError(error.message.toString()))));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Slidable(
      key: Key(recipe.id),
      endActionPane: ActionPane(
        extentRatio: .2,
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            onPressed: (_) => _delete(context),
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            icon: Icons.delete,
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.only(left: 16, right: 8),
        title: Text(recipe.data.title),
        onTap: () => _editRecipe(context),
        trailing: IconButton(
          tooltip: localizations(context).addToShoppingListTooltip,
          icon: const Icon(Icons.add),
          onPressed: () => _addToShoppingList(context),
        ),
      ),
    );
  }
}
