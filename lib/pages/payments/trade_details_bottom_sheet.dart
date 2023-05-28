import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:house_wallet/components/form/date_picker_form_field.dart';
import 'package:house_wallet/components/form/number_form_field.dart';
import 'package:house_wallet/components/ui/custom_bottom_sheet.dart';
import 'package:house_wallet/components/ui/modal_button.dart';
import 'package:house_wallet/data/firestore.dart';
import 'package:house_wallet/data/house/trade.dart';
import 'package:house_wallet/data/house_data.dart';
import 'package:house_wallet/data/logged_user.dart';
import 'package:house_wallet/main.dart';
import 'package:house_wallet/themes.dart';

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

  DateTime? _dateValue;

  num? _amountValue;

  void _saveTrade() async {
    //TODO Quando li modifico scompaiono...
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    _formKey.currentState!.save();
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    setState(() => _loading = true);
    try {
      final trade = Trade(
        description: _descriptionValue,
        amount: _amountValue!,
        date: _dateValue!,
        from: widget.trade.data.from.uid,
        to: widget.trade.data.to.uid,
      );

      await widget.trade.reference.update(Trade.toFirestore(trade));

      navigator.pop();
    } on FirebaseException catch (error) {
      scaffoldMessenger.showSnackBar(SnackBar(content: Text("${localizations(context).saveChangesDialogContentError}\n(${error.message})")));
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
          Text(
            localizations(context).tradeInformationTitle,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          NumberFormField<double>(
            enabled: !_loading,
            initialValue: widget.trade.data.amount.toDouble(),
            decoration: inputDecoration(localizations(context).quantity),
            onSaved: (amount) => _amountValue = amount,
            validator: (amount) {
              if (amount == null) return localizations(context).priceInputErrorMissing;
              if (amount <= 0) return localizations(context).priceInvalid;
              return null;
            },
          ),
          DatePickerFormField(
            enabled: !_loading,
            initialValue: widget.trade.data.date,
            decoration: inputDecoration(localizations(context).paymentDate),
            onSaved: (date) => _dateValue = date,
          ),
          TextFormField(
            enabled: !_loading,
            minLines: 1,
            maxLines: 5,
            initialValue: widget.trade.data.description,
            decoration: inputDecoration(localizations(context).descriptionInput),
            keyboardType: TextInputType.multiline,
            onSaved: (description) => _descriptionValue = (description ?? "").trim().isEmpty ? null : description?.trim(),
          ),
        ],
        actions: [
          ModalButton(enabled: !_loading, onPressed: () => Navigator.of(context).pop(), child: Text(localizations(context).buttonCancel)),
          ModalButton(enabled: !_loading, onPressed: _saveTrade, child: Text(localizations(context).buttonOk)),
        ],
      ),
    );
  }
}
