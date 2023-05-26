import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:house_wallet/components/shopping/shopping_item_tile.dart';
import 'package:house_wallet/components/ui/app_bar_fix.dart';
import 'package:house_wallet/data/logged_user.dart';
import 'package:house_wallet/data/shopping/shopping_item.dart';
import 'package:house_wallet/main.dart';
import 'package:house_wallet/pages/shopping/shopping_bottom_sheet.dart';
import 'package:provider/provider.dart';

class ShoppingPage extends StatelessWidget {
  const ShoppingPage({super.key});

  static CollectionReference<ShoppingItem> firestoreRef(BuildContext context) => FirebaseFirestore.instance.collection("/groups/${Provider.of<LoggedUser>(context).houseId}/shopping").withConverter(fromFirestore: ShoppingItem.fromFirestore, toFirestore: ShoppingItem.toFirestore);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarFix(
        title: Text(localizations(context).shoppingPage),
        shadowColor: Colors.black,
        elevation: 3,
        scrolledUnderElevation: 3,
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: ShoppingPage.firestoreRef(context).snapshots().map(ShoppingItemRef.converter(context)),
              builder: (context, snapshot) {
                final shoppingItems = snapshot.data;

                if (shoppingItems == null) {
                  //TODO error and loading
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: Text("Loading..."));
                  } else {
                    return Center(child: Text("Error (${snapshot.error})"));
                  }
                }

                if (shoppingItems.isEmpty) {
                  //TODO empty message
                  return const Center(child: Text("No data"));
                }

                return SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                    child: Container(
                      clipBehavior: Clip.antiAlias,
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.vertical(bottom: Radius.circular(10)),
                        color: Color(0xFFE6D676),
                      ), //TODO color theme
                      child: Column(
                        children: List.filled(20, shoppingItems.first).map(ShoppingItemTile.new).toList(),
                      ),
                    ),
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
