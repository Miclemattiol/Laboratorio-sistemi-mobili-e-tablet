import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_series/flutter_series.dart';
import 'package:house_wallet/components/shopping/shopping_item_tile.dart';
import 'package:house_wallet/components/ui/app_bar_fix.dart';
import 'package:house_wallet/components/ui/custom_dialog.dart';
import 'package:house_wallet/components/ui/sliding_page_route.dart';
import 'package:house_wallet/data/firestore.dart';
import 'package:house_wallet/data/house_data.dart';
import 'package:house_wallet/data/logged_user.dart';
import 'package:house_wallet/data/payments/category.dart';
import 'package:house_wallet/data/shopping/recipe.dart';
import 'package:house_wallet/data/shopping/shopping_item.dart';
import 'package:house_wallet/main.dart';
import 'package:house_wallet/pages/shopping/buy_items_page.dart';
import 'package:house_wallet/pages/shopping/recipes/recipe_bottom_sheet.dart';
import 'package:house_wallet/pages/shopping/recipes/recipes_page.dart';
import 'package:house_wallet/pages/shopping/shopping_bottom_sheet.dart';
import 'package:house_wallet/themes.dart';
import 'package:house_wallet/utils.dart';
import 'package:shimmer/shimmer.dart';

enum _PopupMenu { recipes, quickAddRecipe }

class ShoppingPageStyle extends ThemeExtension<ShoppingPageStyle> {
  static ShoppingPageStyle of(BuildContext context) => Theme.of(context).extension<ShoppingPageStyle>() ?? const ShoppingPageStyle(shoppingPostItColor: Color(0xFFE6D676));

  final Color shoppingPostItColor;

  const ShoppingPageStyle({required this.shoppingPostItColor});

  @override
  ShoppingPageStyle copyWith({Color? shoppingPostItColor}) => ShoppingPageStyle(shoppingPostItColor: shoppingPostItColor ?? this.shoppingPostItColor);

  @override
  ShoppingPageStyle lerp(ShoppingPageStyle? other, double t) {
    if (other == null) return this;
    return ShoppingPageStyle(shoppingPostItColor: Color.lerp(shoppingPostItColor, other.shoppingPostItColor, t)!);
  }
}

class ShoppingPage extends StatefulWidget {
  final Categories categories;

  const ShoppingPage(this.categories, {super.key});

  static CollectionReference<ShoppingItem> firestoreRef(String houseId) => FirebaseFirestore.instance.collection("/groups/$houseId/shopping").withConverter(fromFirestore: ShoppingItem.fromFirestore, toFirestore: ShoppingItem.toFirestore);

  @override
  State<ShoppingPage> createState() => _ShoppingPageState();
}

class _ShoppingPageState extends State<ShoppingPage> {
  late final _stream = ShoppingPage.firestoreRef(HouseDataRef.of(context).id).orderBy(ShoppingItem.timestampKey, descending: true).snapshots().map(ShoppingItemRef.converter(context));
  final _checkedItems = <String, FirestoreDocument<ShoppingItemRef>>{};

  Widget _shoppingList(Widget child) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(10)),
            color: ShoppingPageStyle.of(context).shoppingPostItColor,
          ),
          child: child,
        ),
      ),
    );
  }

  // void _delete(BuildContext context, FirestoreDocument<ShoppingItemRef> shoppingItem) async {
  //   final scaffoldMessenger = ScaffoldMessenger.of(context);
  //   final appLocalizations = localizations(context);

  //   if (await isNotConnectedToInternet(context) || !context.mounted) return;

  //   try {
  //     await shoppingItem.reference.delete();
  //   } on FirebaseException catch (error) {
  //     scaffoldMessenger.showSnackBar(SnackBar(content: Text(appLocalizations.actionError(error.message.toString()))));
  //   }
  // }

  void _deleteSelected(BuildContext context, List<FirestoreDocument<ShoppingItemRef>> shoppingItem) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final appLocalizations = localizations(context);

    if (await isNotConnectedToInternet(context) || !context.mounted) return;

    try {
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        for (final item in shoppingItem) {
          transaction.delete(item.reference);
        }
      });
    } on FirebaseException catch (error) {
      scaffoldMessenger.showSnackBar(SnackBar(content: Text(appLocalizations.actionError(error.message.toString()))));
    }
  }

  void _confirmPurchase() {
    Navigator.of(context).push(
      SlidingPageRoute(
        BuyItemsPage(
          _checkedItems.values.toList(),
          categories: widget.categories,
          loggedUser: LoggedUser.of(context, listen: false),
          house: HouseDataRef.of(context, listen: false),
          onComplete: () => setState(() => _checkedItems.clear()),
          onRemoved: (item) => setState(() => _checkedItems.remove(item.id)),
        ),
        fullscreenDialog: true,
      ),
    );
  }

  void _updateCheckedItems(Iterable<FirestoreDocument<ShoppingItemRef>> shoppingItems) {
    final wasNotEmpty = _checkedItems.isNotEmpty;
    final newItems = Map<String, FirestoreDocument<ShoppingItemRef>>.fromEntries(shoppingItems.map((item) => MapEntry(item.id, item)));

    _checkedItems.removeWhere((key, value) => !newItems.containsKey(key));
    for (final key in _checkedItems.keys) {
      _checkedItems[key] = newItems[key]!;
    }

    if (wasNotEmpty && _checkedItems.isEmpty) setState(() {});
  }

  Widget _buildShimmer() {
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
  }

  List<Widget> _buildActions() {
    final house = HouseDataRef.of(context, listen: false);
    return [
      if (_checkedItems.isNotEmpty)
        IconButton(
          tooltip: localizations(context).delete,
          // onPressed: () => setState(() async => _checkedItems.forEach((key, value) => _delete(context, value))),
          onPressed: () async => {
            await CustomDialog.confirm(context: context, title: localizations(context).delete, content: localizations(context).shoppingPageRemoveElement)
                ? {
                    _deleteSelected(context, _checkedItems.values.toList()),
                    setState(() => _checkedItems.clear()),
                  }
                : null
          },
          icon: const Icon(Icons.delete),
        ),
      // IconButton(
      //   tooltip: localizations(context).buyItemsTooltip,
      //   onPressed: _checkedItems.isEmpty ? null : _confirmPurchase,
      //   icon: const Icon(Icons.shopping_cart),
      // ),
      PopupMenuButton<_PopupMenu>(
        onSelected: (value) async {
          switch (value) {
            case _PopupMenu.recipes:
              Navigator.of(context).push(SlidingPageRoute(RecipesPage(house: house), fullscreenDialog: true));
              break;
            case _PopupMenu.quickAddRecipe:
              if (await isNotConnectedToInternet(context) || !context.mounted) return;
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                enableDrag: false,
                builder: (context) => RecipeBottomSheet.quickAddRecipe(
                  _checkedItems.values.map((item) {
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
            enabled: _checkedItems.isNotEmpty,
            child: PadRow(
              crossAxisAlignment: CrossAxisAlignment.center,
              spacing: 16,
              children: [
                const Icon(Icons.assignment_add),
                Expanded(child: Text(localizations(context).quickRecipeTooltip)),
              ],
            ),
          ),
        ],
        offset: const Offset(0, 64),
      )
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: _checkedItems.isEmpty
          ? null
          : Padding(
              padding: const EdgeInsets.only(bottom: 64),
              child: FloatingActionButton.extended(
                onPressed: _confirmPurchase,
                label: PadRow(
                  mainAxisAlignment: MainAxisAlignment.center,
                  spacing: 8,
                  children: [
                    const Icon(Icons.shopping_cart),
                    Text(localizations(context).shoppingPageAddToCart),
                  ],
                ),
              ),
            ),
      appBar: AppBarFix(
        title: Text(localizations(context).shoppingPage),
        shadowColor: Colors.black,
        elevation: 3,
        scrolledUnderElevation: 3,
        actions: _buildActions(),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: _stream,
              builder: (context, snapshot) {
                final shoppingItems = snapshot.data;

                if (shoppingItems == null) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return _buildShimmer();
                  } else {
                    return centerErrorText(context: context, message: localizations(context).shoppingPageError, error: snapshot.error);
                  }
                }

                WidgetsBinding.instance.addPostFrameCallback((_) => _updateCheckedItems(shoppingItems));

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
                        checked: _checkedItems.containsKey(shoppingItem.id),
                        setChecked: (value) => setState(() {
                          if (value) {
                            _checkedItems[shoppingItem.id] = shoppingItem;
                          } else {
                            _checkedItems.remove(shoppingItem.id);
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
