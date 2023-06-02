import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_series/flutter_series.dart';
import 'package:house_wallet/components/shopping/shopping_item_tile_buy_page.dart';
import 'package:house_wallet/components/ui/app_bar_fix.dart';
import 'package:house_wallet/components/ui/dropdown_list_tile.dart';
import 'package:house_wallet/components/ui/modal_button.dart';
import 'package:house_wallet/data/firestore.dart';
import 'package:house_wallet/data/house_data.dart';
import 'package:house_wallet/data/logged_user.dart';
import 'package:house_wallet/data/shopping/shopping_item.dart';
import 'package:house_wallet/main.dart';

class BuyItemsPage extends StatefulWidget {
  final LoggedUser loggedUser;
  final HouseDataRef house;
  final List<FirestoreDocument<ShoppingItemRef>> shoppingItems;
  final void Function() onComplete;

  const BuyItemsPage(
    this.shoppingItems, {
    required this.loggedUser,
    required this.house,
    required this.onComplete,
    super.key,
  });

  @override
  State<BuyItemsPage> createState() => _BuyItemsPageState();
}

class _BuyItemsPageState extends State<BuyItemsPage> {
  late final Map<String, num?> _prices = Map.fromEntries(widget.shoppingItems.map((item) => MapEntry(item.id, item.data.price)).toList());

  late String _payAsValue = widget.loggedUser.uid; //TODO use this value when adding the payment

  void _confirmPurchase() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final appLocalizations = localizations(context);

    try {
      final batch = FirebaseFirestore.instance.batch();

      for (final item in widget.shoppingItems) {
        batch.delete(item.reference);
      }
      _payAsValue; //TODO add payment
      await batch.commit();

      widget.onComplete();
      navigator.pop();
    } on FirebaseException catch (error) {
      scaffoldMessenger.showSnackBar(SnackBar(content: Text(appLocalizations.saveChangesError(error.message.toString()))));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarFix(
        title: Text(localizations(context).buyItemsPage),
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        children: widget.shoppingItems.map((item) {
          return ShoppingItemTileBuyPage(
            item,
            onChanged: (value) => setState(() => _prices[item.id] = value),
          );
        }).toList(),
      ),
      bottomNavigationBar: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Divider(height: 0),
            DropdownListTile<String>(
              initialValue: widget.loggedUser.uid,
              title: Text(localizations(context).payAs),
              onChanged: (value) => _payAsValue = value ?? widget.loggedUser.uid,
              values: widget.house.users.values.map((user) {
                return DropdownMenuItem(value: user.uid, child: Text(user.username));
              }).toList(),
            ),
            ListTile(
              title: Text(localizations(context).totalPrice, style: Theme.of(context).textTheme.headlineMedium),
              trailing: Text(currencyFormat(context).format(_prices.values.fold<num>(0, (prev, price) => prev + (price ?? 0))), style: Theme.of(context).textTheme.headlineSmall),
            ),
            PadRow(
              spacing: 1,
              children: [
                Expanded(child: ModalButton(onPressed: () => Navigator.of(context).pop(), child: Text(localizations(context).cancel))),
                Expanded(child: ModalButton(onPressed: _confirmPurchase, child: Text(localizations(context).pay))),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
