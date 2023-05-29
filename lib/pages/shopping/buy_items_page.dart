import 'package:flutter/material.dart';
import 'package:house_wallet/components/ui/app_bar_fix.dart';
import 'package:house_wallet/data/firestore.dart';
import 'package:house_wallet/data/shopping/shopping_item.dart';
import 'package:house_wallet/main.dart';

//TODO buy items page
class BuyItemsPage extends StatelessWidget {
  final List<FirestoreDocument<ShoppingItemRef>> shoppingItems;

  const BuyItemsPage(
    this.shoppingItems, {
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarFix(
        title: Text(localizations(context).buyItemsPage),
      ),
      body: ListView(
        children: const [
          Text("TODO")
        ],
      ),
    );
  }
}
