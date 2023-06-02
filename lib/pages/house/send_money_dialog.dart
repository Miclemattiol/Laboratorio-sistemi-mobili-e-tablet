import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_series/flutter_series.dart';
import 'package:house_wallet/components/form/copy_form_field.dart';
import 'package:house_wallet/components/form/number_form_field.dart';
import 'package:house_wallet/components/house/trade/trades_section.dart';
import 'package:house_wallet/components/ui/custom_dialog.dart';
import 'package:house_wallet/components/ui/modal_button.dart';
import 'package:house_wallet/data/house_data.dart';
import 'package:house_wallet/data/logged_user.dart';
import 'package:house_wallet/data/payments/trade.dart';
import 'package:house_wallet/data/user.dart';
import 'package:house_wallet/main.dart';
import 'package:house_wallet/themes.dart';
import 'package:house_wallet/utils.dart';
import 'package:url_launcher/url_launcher.dart';

final _payPalLogo = base64Decode("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");

class SendMoneyDialog extends StatefulWidget {
  final User user;
  final LoggedUser loggedUser;
  final HouseDataRef house;

  const SendMoneyDialog(
    this.user, {
    required this.loggedUser,
    required this.house,
    super.key,
  });

  @override
  State<SendMoneyDialog> createState() => _SendMoneyDialogState();
}

class _SendMoneyDialogState extends State<SendMoneyDialog> {
  final _formKey = GlobalKey<FormState>();
  bool _loading = false;

  num? _priceValue;
  String? _descriptionValue;

  final TextEditingController _descriptionController = TextEditingController();

  void _addTrade(BuildContext context) async {
    final navigator = Navigator.of(context);

    _formKey.currentState!.save();
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    try {
      await TradesSection.firestoreRef(widget.house.id).add(Trade(
        amount: _priceValue!,
        from: widget.loggedUser.uid,
        to: widget.user.uid,
        date: DateTime.now(),
        description: _descriptionValue,
      ));
      navigator.pop(true);
    } on FirebaseException catch (error) {
      CustomDialog.alert(
        context: context,
        title: localizations(context).error,
        content: localizations(context).actionError(error.message.toString()),
      );
      setState(() => _loading = false);
    }
  }

  void _payWithPayPal() {
    if (widget.user.payPal == null) return;

    try {
      launchUrl(Uri.parse("https://paypal.me/${widget.user.payPal}"), mode: LaunchMode.externalApplication);
      if (_descriptionController.text.isNotEmpty) Clipboard.setData(ClipboardData(text: _descriptionController.text));
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: CustomDialog(
        dismissible: false,
        spacing: 12,
        body: [
          NumberFormField<num>(
            enabled: !_loading,
            initialValue: () {
              final balance = widget.house.getBalance(widget.user.uid);
              return balance <= 0 ? null : balance;
            }(),
            decoration: inputDecoration(localizations(context).price),
            decimal: true,
            validator: (price) => (price == null || price == 0) ? localizations(context).priceMissing : null,
            onSaved: (price) => _priceValue = price,
          ),
          TextFormField(
            enabled: !_loading,
            minLines: 1,
            maxLines: 5,
            controller: _descriptionController,
            decoration: inputDecoration(localizations(context).description),
            keyboardType: TextInputType.multiline,
            onSaved: (description) => _descriptionValue = description.toNullable(),
          ),
          if (widget.user.iban != null) CopyFormField(widget.user.iban!, decoration: inputDecoration(localizations(context).iban)),
          if (widget.user.payPal != null)
            ElevatedButton(
              onPressed: _payWithPayPal,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFC43A),
                foregroundColor: Colors.black,
                textStyle: const TextStyle(fontWeight: FontWeight.normal),
              ),
              child: PadRow(
                spacing: 8,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(localizations(context).payWith),
                  Image.memory(_payPalLogo, height: 18),
                ],
              ),
            ),
        ],
        actions: [
          ModalButton(onPressed: () => Navigator.of(context).pop(), child: Text(localizations(context).cancel)),
          ModalButton(onPressed: () => _addTrade(context), child: Text(localizations(context).pay)),
        ],
      ),
    );
  }
}
