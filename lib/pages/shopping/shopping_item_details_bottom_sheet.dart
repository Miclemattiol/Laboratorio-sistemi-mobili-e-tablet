import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_series/flutter_series.dart';
import 'package:house_wallet/components/form/number_form_field.dart';
import 'package:house_wallet/components/form/people_share_form_field.dart';
import 'package:house_wallet/components/ui/custom_bottom_sheet.dart';
import 'package:house_wallet/components/ui/custom_dialog.dart';
import 'package:house_wallet/components/ui/modal_button.dart';
import 'package:house_wallet/data/firestore.dart';
import 'package:house_wallet/data/house_data.dart';
import 'package:house_wallet/data/shopping/shopping_item.dart';
import 'package:house_wallet/main.dart';
import 'package:house_wallet/themes.dart';
import 'package:house_wallet/utils.dart';

class ShoppingItemDetailsBottomSheet extends StatefulWidget {
  final FirestoreDocument<ShoppingItemRef> shoppingItem;
  final HouseDataRef house;

  const ShoppingItemDetailsBottomSheet(
    this.shoppingItem, {
    required this.house,
    super.key,
  });

  @override
  State<ShoppingItemDetailsBottomSheet> createState() => _ShoppingItemDetailsBottomSheetState();
}

class _ShoppingItemDetailsBottomSheetState extends State<ShoppingItemDetailsBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  bool _loading = false;

  num? _priceValue;
  int? _quantityValue;
  String? _supermarketValue;
  String? _titleValue;
  Shares? _toValue;

  void _saveShoppingItem() async {
    final navigator = Navigator.of(context);

    _formKey.currentState!.save();
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    try {
      await widget.shoppingItem.reference.update({
        ShoppingItem.priceKey: _priceValue,
        ShoppingItem.quantityKey: _quantityValue,
        ShoppingItem.supermarketKey: _supermarketValue,
        ShoppingItem.titleKey: _titleValue!,
        ShoppingItem.toKey: _toValue!,
      });
      navigator.pop();
    } on FirebaseException catch (error) {
      if (!context.mounted) return;
      CustomDialog.alert(
        context: context,
        title: localizations(context).error,
        content: localizations(context).saveChangesError(error.message.toString()),
      );
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: CustomBottomSheet(
        dismissible: !_loading,
        spacing: 16,
        body: [
          PadRow(
            spacing: 16,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: TextFormField(
                  enabled: !_loading,
                  initialValue: widget.shoppingItem.data.title,
                  decoration: inputDecoration(localizations(context).title),
                  validator: (title) => (title == null || title.trim().isEmpty) ? localizations(context).titleMissing : null,
                  onSaved: (title) => _titleValue = title,
                ),
              ),
              ConstrainedBox(
                constraints: multiInputRowConstraints(context),
                child: NumberFormField(
                  enabled: !_loading,
                  initialValue: widget.shoppingItem.data.price,
                  decoration: inputDecoration(localizations(context).price),
                  decimal: true,
                  onSaved: (price) => _priceValue = price,
                ),
              ),
            ],
          ),
          PadRow(
            spacing: 16,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: TextFormField(
                  enabled: !_loading,
                  initialValue: widget.shoppingItem.data.supermarket,
                  decoration: inputDecoration(localizations(context).supermarket),
                  onSaved: (supermarket) => _supermarketValue = supermarket.toNullable(),
                ),
              ),
              ConstrainedBox(
                constraints: multiInputRowConstraints(context),
                child: NumberFormField<int>(
                  enabled: !_loading,
                  initialValue: widget.shoppingItem.data.quantity,
                  decoration: inputDecoration(localizations(context).quantity),
                  onSaved: (quantity) => _quantityValue = quantity,
                ),
              ),
            ],
          ),
          PeopleSharesFormField(
            enabled: !_loading,
            house: widget.house,
            initialValue: widget.shoppingItem.data.to.map((key, value) => MapEntry(key, value.share)),
            decoration: inputDecoration(localizations(context).peopleShares),
            onSaved: (to) => _toValue = to,
          ),
        ],
        actions: [
          ModalButton(enabled: !_loading, onPressed: () => Navigator.of(context).pop(), child: Text(localizations(context).cancel)),
          ModalButton(enabled: !_loading, onPressed: _saveShoppingItem, child: Text(localizations(context).ok)),
        ],
      ),
    );
  }
}
