import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' hide Category;
import 'package:flutter/material.dart';
import 'package:flutter_series/flutter_series.dart';
import 'package:house_wallet/components/form/category_form_field.dart';
import 'package:house_wallet/components/shopping/shopping_item_tile_buy_page.dart';
import 'package:house_wallet/components/ui/app_bar_fix.dart';
import 'package:house_wallet/components/ui/custom_dialog.dart';
import 'package:house_wallet/components/ui/dropdown_list_tile.dart';
import 'package:house_wallet/components/ui/modal_button.dart';
import 'package:house_wallet/data/firestore.dart';
import 'package:house_wallet/data/house_data.dart';
import 'package:house_wallet/data/logged_user.dart';
import 'package:house_wallet/data/payments/category.dart';
import 'package:house_wallet/data/payments/payment.dart';
import 'package:house_wallet/data/shopping/shopping_item.dart';
import 'package:house_wallet/main.dart';
import 'package:house_wallet/pages/payments/categories/category_dialog.dart';
import 'package:house_wallet/pages/payments/payments_page.dart';
import 'package:house_wallet/pages/shopping/price_quantity_dialog.dart';
import 'package:house_wallet/themes.dart';
import 'package:house_wallet/utils.dart';

class BuyItemsPage extends StatefulWidget {
  final List<FirestoreDocument<ShoppingItemRef>> shoppingItems;
  final List<FirestoreDocument<Category>> categories;
  final LoggedUser loggedUser;
  final HouseDataRef house;
  final void Function() onComplete;

  const BuyItemsPage(
    this.shoppingItems, {
    required this.categories,
    required this.loggedUser,
    required this.house,
    required this.onComplete,
    super.key,
  });

  @override
  State<BuyItemsPage> createState() => _BuyItemsPageState();
}

class _BuyItemsPageState extends State<BuyItemsPage> {
  late final Map<String, PriceQuantity?> _pricesQuantities = Map.fromEntries(widget.shoppingItems.map((item) => MapEntry(item.id, PriceQuantity(item.data.price, item.data.quantity))).toList());
  late String _payAsValue = widget.loggedUser.uid;

  Future<String?> _categoryPrompt() async {
    String? categoryValue;

    void returnValue(BuildContext context) async {
      final navigator = Navigator.of(context);

      if (categoryValue == CategoryFormField.newCategoryKey) {
        categoryValue = await showDialog<String?>(context: context, builder: (context) => CategoryDialog(house: widget.house));
        if (categoryValue == null) return navigator.pop<String?>();
      }

      if (mounted) {
        Navigator.of(context).pop<String?>(categoryValue ?? CategoryFormField.noCategoryKey);
      }
    }

    return await showDialog<String>(
      context: context,
      builder: (context) => CustomDialog(
        dismissible: false,
        padding: const EdgeInsets.all(24),
        crossAxisAlignment: CrossAxisAlignment.center,
        body: [
          CategoryFormField(
            categories: widget.categories,
            decoration: inputDecoration(localizations(context).category),
            onChanged: (category) => categoryValue = category,
          ),
        ],
        actions: [
          ModalButton(onPressed: () => Navigator.of(context).pop<String?>(), child: Text(localizations(context).cancel)),
          ModalButton(onPressed: () => returnValue(context), child: Text(localizations(context).ok)),
        ],
      ),
    );
  }

  void _confirmPurchase() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final appLocalizations = localizations(context);

    if (await isNotConnectedToInternet(context) || !context.mounted) return;

    final category = await _categoryPrompt();
    if (category == null) return;

    final groupedItems = <Shares, List<FirestoreDocument<ShoppingItemRef>>>{};
    List<FirestoreDocument<ShoppingItemRef>> getShareList(shares) => groupedItems.entries.firstWhere((entry) => mapEquals(entry.key, shares), orElse: () => MapEntry(shares, groupedItems[shares] = [])).value;

    for (final item in widget.shoppingItems) {
      final shares = item.data.shares.isNotEmpty ? item.data.shares : widget.house.users.map((key, _) => MapEntry(key, 1));
      getShareList(shares).add(item);
    }

    try {
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        for (final item in widget.shoppingItems) {
          transaction.delete(item.reference);
        }

        List<UpdateData> balanceUpdateData = [];

        for (final group in groupedItems.entries) {
          final price = group.value.fold<num>(0, (prev, item) {
            final price = _pricesQuantities[item.id]?.price ?? 0;
            final quantity = _pricesQuantities[item.id]?.quantity ?? 1;
            return prev + price * quantity;
          });

          transaction.set<Payment>(
            PaymentsPage.paymentsFirestoreRef(widget.house.id).doc(),
            Payment(
              title: appLocalizations.shoppingPage,
              category: category == CategoryFormField.noCategoryKey ? null : category,
              description: group.value.map((item) => item.data.title).join(", "),
              price: price,
              imageUrl: null,
              date: DateTime.now(),
              from: _payAsValue,
              to: group.key,
            ),
          );

          balanceUpdateData.add(UpdateData(newValues: SharesData(from: _payAsValue, price: price, shares: group.key)));
        }

        widget.house.updateBalances(transaction, balanceUpdateData);
      });

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
            value: _pricesQuantities[item.id] ?? const PriceQuantity(null, null),
            onChanged: (value) => setState(() => _pricesQuantities[item.id] = value),
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
              trailing: Text(
                currencyFormat(context).format(_pricesQuantities.values.fold<num>(0, (prev, value) => prev + (value?.quantity ?? 1) * (value?.price ?? 0))),
                style: Theme.of(context).textTheme.headlineSmall,
              ),
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
