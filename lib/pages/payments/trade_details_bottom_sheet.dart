import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:house_wallet/components/form/date_picker_form_field.dart';
import 'package:house_wallet/components/form/number_form_field.dart';
import 'package:house_wallet/components/ui/custom_bottom_sheet.dart';
import 'package:house_wallet/components/ui/custom_dialog.dart';
import 'package:house_wallet/components/ui/modal_button.dart';
import 'package:house_wallet/data/firestore.dart';
import 'package:house_wallet/data/house_data.dart';
import 'package:house_wallet/data/logged_user.dart';
import 'package:house_wallet/data/payments/trade.dart';
import 'package:house_wallet/main.dart';
import 'package:house_wallet/themes.dart';
import 'package:house_wallet/utils.dart';

class TradeDetailsBottomSheet extends StatefulWidget {
  final LoggedUser loggedUser;
  final HouseDataRef house;
  final FirestoreDocument<TradeRef> trade;

  const TradeDetailsBottomSheet.edit(
    this.trade, {
    required this.loggedUser,
    required this.house,
    super.key,
  });

  @override
  State<TradeDetailsBottomSheet> createState() => _TradeDetailsBottomSheetState();
}

class _TradeDetailsBottomSheetState extends State<TradeDetailsBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  bool _loading = false;

  String? _descriptionValue;
  num? _amountValue;
  DateTime? _dateValue;

  void _saveTrade() async {
    final navigator = Navigator.of(context);

    _formKey.currentState!.save();
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    try {
      final trade = widget.trade.data;
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        transaction.update(
          widget.trade.reference,
          {
            Trade.descriptionKey: _descriptionValue,
            Trade.amountKey: _amountValue!,
            Trade.dateKey: _dateValue!,
          },
        );

        widget.house.updateBalances(
          transaction,
          [
            UpdateData(
              prevValues: SharesData(from: trade.from.uid, price: trade.price, shares: trade.shares),
              newValues: SharesData(from: trade.from.uid, price: _amountValue!, shares: trade.shares),
            )
          ],
        );
      });

      navigator.pop();
    } on FirebaseException catch (error) {
      if (!context.mounted) return;
      CustomDialog.alert(
        context: context,
        title: localizations(context).error,
        content: error.code == HouseDataRef.invalidUsersError ? localizations(context).balanceInvalidUser : localizations(context).saveChangesError(error.message.toString()),
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
          NumberFormField(
            enabled: !_loading,
            initialValue: widget.trade.data.price,
            decoration: inputDecoration(localizations(context).amount),
            decimal: true,
            onSaved: (amount) => _amountValue = amount,
            validator: (amount) => (amount == null) ? localizations(context).priceMissing : null,
          ),
          DatePickerFormField(
            enabled: !_loading,
            initialValue: widget.trade.data.date,
            lastDate: DateTime.now(),
            decoration: inputDecoration(localizations(context).date),
            onSaved: (date) => _dateValue = date,
          ),
          TextFormField(
            enabled: !_loading,
            minLines: 1,
            maxLines: 5,
            initialValue: widget.trade.data.description,
            decoration: inputDecoration(localizations(context).description),
            keyboardType: TextInputType.multiline,
            onSaved: (description) => _descriptionValue = description.toNullable(),
          ),
        ],
        actions: [
          ModalButton(enabled: !_loading, onPressed: () => Navigator.of(context).pop(), child: Text(localizations(context).cancel)),
          ModalButton(enabled: !_loading, onPressed: _saveTrade, child: Text(localizations(context).ok)),
        ],
      ),
    );
  }
}
