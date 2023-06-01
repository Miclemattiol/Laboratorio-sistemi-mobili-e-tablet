import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_series/flutter_series.dart';
import 'package:house_wallet/components/shopping/shopping_item_tile.dart';
import 'package:house_wallet/components/ui/app_bar_fix.dart';
import 'package:house_wallet/components/ui/sliding_page_route.dart';
import 'package:house_wallet/data/firestore.dart';
import 'package:house_wallet/data/house_data.dart';
import 'package:house_wallet/data/logged_user.dart';
import 'package:house_wallet/data/shopping/recipe.dart';
import 'package:house_wallet/data/shopping/shopping_item.dart';
import 'package:house_wallet/main.dart';
import 'package:house_wallet/pages/shopping/buy_items_page.dart';
import 'package:house_wallet/pages/shopping/recipes/recipe_bottom_sheet.dart';
import 'package:house_wallet/pages/shopping/recipes/recipes_page.dart';
import 'package:house_wallet/pages/shopping/shopping_bottom_sheet.dart';
import 'package:house_wallet/themes.dart';
import 'package:shimmer/shimmer.dart';

enum _PopupMenu {
  recipes,
  quickAddRecipe
}

class ShoppingPage extends StatefulWidget {
  const ShoppingPage({super.key});

  static CollectionReference<ShoppingItem> firestoreRef(String houseId) => FirebaseFirestore.instance.collection("/groups/$houseId/shopping").withConverter(fromFirestore: ShoppingItem.fromFirestore, toFirestore: ShoppingItem.toFirestore);

  @override
  State<ShoppingPage> createState() => _ShoppingPageState();
}

class _ShoppingPageState extends State<ShoppingPage> {
  Map<String, FirestoreDocument<ShoppingItemRef>> _shoppingItems = {};
  final _checkedIds = <String>{};

  Widget _shoppingList(Widget child) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
        child: Container(
          clipBehavior: Clip.antiAlias,
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(10)),
            color: Color(0xFFE6D676), //TODO color theme
          ),
          child: child,
        ),
      ),
    );
  }

  List<FirestoreDocument<ShoppingItemRef>> _checkedItems() {
    return _checkedIds.expand<FirestoreDocument<ShoppingItemRef>>((id) {
      if (_shoppingItems.containsKey(id)) {
        return [
          _shoppingItems[id]!
        ];
      }
      return [];
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarFix(
        title: Text(localizations(context).shoppingPage),
        shadowColor: Colors.black,
        elevation: 3,
        scrolledUnderElevation: 3,
        actions: [
          IconButton(
            tooltip: localizations(context).buyItemsTooltip,
            onPressed: _checkedIds.isEmpty
                ? null
                : () {
                    Navigator.of(context).push(
                      SlidingPageRoute(
                        BuyItemsPage(
                          _checkedItems(),
                          loggedUser: LoggedUser.of(context, listen: false),
                          house: HouseDataRef.of(context, listen: false),
                          onComplete: () => setState(() => _checkedIds.clear()),
                        ),
                        fullscreenDialog: true,
                      ),
                    );
                  },
            icon: const Icon(Icons.shopping_cart),
          ),
          PopupMenuButton<_PopupMenu>(
            onSelected: (value) {
              final house = HouseDataRef.of(context, listen: false);

              switch (value) {
                case _PopupMenu.recipes:
                  Navigator.of(context).push(SlidingPageRoute(RecipesPage(house: house), fullscreenDialog: true));
                  break;
                case _PopupMenu.quickAddRecipe:
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    enableDrag: false,
                    builder: (context) => RecipeBottomSheet.quickAddRecipe(
                      _checkedItems().map((item) {
                        return RecipeItem(
                          title: item.data.title,
                          price: item.data.price,
                          quantity: item.data.quantity,
                          supermarket: item.data.supermarket,
                        );
                      }).toList(),
                      house: house,
                    ),
                  );
                  break;
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: _PopupMenu.recipes,
                child: PadRow(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  spacing: 16,
                  children: [
                    const Icon(Icons.assignment),
                    Expanded(child: Text(localizations(context).recipesPage)),
                  ],
                ),
              ),
              PopupMenuItem(
                value: _PopupMenu.quickAddRecipe,
                enabled: _checkedIds.isNotEmpty,
                child: PadRow(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  spacing: 16,
                  children: [
                    const Icon(Icons.add),
                    Expanded(child: Text(localizations(context).quickRecipeTooltip)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: ShoppingPage.firestoreRef(HouseDataRef.of(context).id).orderBy(ShoppingItem.timestampKey, descending: true).snapshots().map(ShoppingItemRef.converter(context)),
              builder: (context, snapshot) {
                final shoppingItems = snapshot.data;

                if (shoppingItems == null) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return _shoppingList(Shimmer.fromColors(
                      baseColor: Theme.of(context).disabledColor,
                      highlightColor: Theme.of(context).disabledColor.withOpacity(.1),
                      child: Column(
                        children: [
                          ShoppingItemTile.shimmer(titleWidth: 128),
                          ShoppingItemTile.shimmer(titleWidth: 48),
                          ShoppingItemTile.shimmer(titleWidth: 80),
                          ShoppingItemTile.shimmer(titleWidth: 112),
                          ShoppingItemTile.shimmer(titleWidth: 64),
                          ShoppingItemTile.shimmer(titleWidth: 128),
                          ShoppingItemTile.shimmer(titleWidth: 96),
                        ],
                      ),
                    ));
                  } else {
                    return centerErrorText(context: context, message: localizations(context).shoppingPageError, error: snapshot.error);
                  }
                }

                _shoppingItems = Map.fromEntries(shoppingItems.map((item) => MapEntry(item.id, item)));

                if (shoppingItems.isEmpty) {
                  return centerSectionText(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(localizations(context).shoppingPageEmpty, textAlign: TextAlign.center, style: Theme.of(context).textTheme.headlineMedium),
                        Text(localizations(context).shoppingPageEmptyDescription, textAlign: TextAlign.center, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.normal)),
                      ],
                    ),
                  );
                }

                return _shoppingList(
                  Column(
                    children: shoppingItems.map((shoppingItem) {
                      return ShoppingItemTile(
                        shoppingItem,
                        checked: _checkedIds.contains(shoppingItem.id),
                        setChecked: (value) => setState(() {
                          if (value) {
                            _checkedIds.add(shoppingItem.id);
                          } else {
                            _checkedIds.remove(shoppingItem.id);
                          }
                        }),
                      );
                    }).toList(),
                  ),
                );
              },
            ),
          ),
          const ShoppingBottomSheet()
        ],
      ),
    );
  }
}
