import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:house_wallet/components/shopping/shopping_item_tile.dart';
import 'package:house_wallet/components/ui/app_bar_fix.dart';
import 'package:house_wallet/data/firestore.dart';
import 'package:house_wallet/data/logged_user.dart';
import 'package:house_wallet/data/shopping/shopping_item.dart';
import 'package:house_wallet/main.dart';

class ShoppingPage extends StatelessWidget {
  const ShoppingPage({super.key});

  static CollectionReference<ShoppingItem> get firestoreRef => FirebaseFirestore.instance.collection("/groups/${LoggedUser.houseId}/shopping").withConverter(fromFirestore: ShoppingItem.fromFirestore, toFirestore: ShoppingItem.toFirestore);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarFix(title: Text(localizations(context).shoppingPage)),
      body: StreamBuilder(
        stream: ShoppingPage.firestoreRef.snapshots().map(defaultFirestoreConverter),
        builder: (context, snapshot) {
          final shoppingItems = snapshot.data;

          if (shoppingItems == null) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: Text("Loading..."));
            } else {
              return Center(child: Text("Error (${snapshot.error})"));
            }
          }

          if (shoppingItems.isEmpty) {
            return const Center(child: Text("No data"));
          }

          return ListView(children: shoppingItems.map(ShoppingItemTile.new).toList());
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => ShoppingPage.firestoreRef.add(const ShoppingItem(number: 0)),
        child: const Icon(Icons.add),
      ),
    );
  }
}
