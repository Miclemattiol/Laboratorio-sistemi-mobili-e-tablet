import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:house_wallet/components/shopping/shopping_item_tile.dart';
import 'package:house_wallet/components/ui/app_bar_fix.dart';
import 'package:house_wallet/data/house_data.dart';
import 'package:house_wallet/data/shopping/shopping_item.dart';
import 'package:house_wallet/main.dart';
import 'package:house_wallet/pages/shopping/shopping_bottom_sheet.dart';
import 'package:house_wallet/themes.dart';
import 'package:shimmer/shimmer.dart';

class ShoppingPage extends StatelessWidget {
  const ShoppingPage({super.key});

  static CollectionReference<ShoppingItem> firestoreRef(String houseId) => FirebaseFirestore.instance.collection("/groups/$houseId/shopping").withConverter(fromFirestore: ShoppingItem.fromFirestore, toFirestore: ShoppingItem.toFirestore);

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarFix(
        title: Text(localizations(context).shoppingPage),
        shadowColor: Colors.black,
        elevation: 3,
        scrolledUnderElevation: 3,
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.shopping_cart)), //TODO acquisto, tooltip
          PopupMenuButton(
            //TODO ricette
            itemBuilder: (context) => [
              const PopupMenuItem(child: Text("TODO 1")),
              const PopupMenuItem(enabled: false, child: Text("TODO 2"))
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: ShoppingPage.firestoreRef(HouseDataRef.of(context).id).snapshots().map(ShoppingItemRef.converter(context)),
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

                //TODO empty list
                if (shoppingItems.isEmpty) {
                  return const Center(child: Text("🗿", style: TextStyle(fontSize: 64)));
                }

                return _shoppingList(Column(children: shoppingItems.map(ShoppingItemTile.new).toList()));
              },
            ),
          ),
          const ShoppingBottomSheet()
        ],
      ),
    );
  }
}
