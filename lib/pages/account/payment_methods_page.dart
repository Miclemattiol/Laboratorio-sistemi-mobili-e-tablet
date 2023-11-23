import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_series/flutter_series.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:house_wallet/components/ui/app_bar_fix.dart';
import 'package:house_wallet/components/ui/modal_button.dart';
import 'package:house_wallet/data/logged_user.dart';
import 'package:house_wallet/data/user.dart';
import 'package:house_wallet/main.dart';
import 'package:house_wallet/pages/main_page.dart';
import 'package:house_wallet/themes.dart';
import 'package:house_wallet/utils.dart';

class PaymentMethodsPage extends StatefulWidget {
  final LoggedUser loggedUser;
  final User user;

  const PaymentMethodsPage({
    required this.loggedUser,
    required this.user,
    super.key,
  });

  @override
  State<PaymentMethodsPage> createState() => _PaymentMethodsPageState();
}

class _PaymentMethodsPageState extends State<PaymentMethodsPage> {
  String? _ibanValue;
  String? _payPalValue;
  final _formKey = GlobalKey<FormState>();
  bool _edited = false;
  bool _loading = false;

  void _saveChanges() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final appLocalizations = localizations(context);
    final navigator = Navigator.of(context);

    _formKey.currentState!.save();

    try {
      if (await isNotConnectedToInternet(context) || !mounted) return mounted ? setState(() => _loading = false) : null;

      await MainPage.userFirestoreRef(widget.loggedUser.uid).update({
        User.ibanKey: _ibanValue,
        User.payPalKey: _payPalValue,
      });

      _edited = false;
      scaffoldMessenger.showSnackBar(SnackBar(content: Text(appLocalizations.saveChangesSuccess)));
      navigator.pop();
    } on FirebaseException catch (error) {
      scaffoldMessenger.showSnackBar(SnackBar(content: Text(appLocalizations.saveChangesError(error.message.toString()))));
    } finally {
      setState(() => _loading = false);
    }
  }

  void _discardChanges() {
    final navigator = Navigator.of(context);
    _formKey.currentState!.reset();
    setState(() => _edited = false);
    navigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Scaffold(
        appBar: AppBarFix(
          title: Text(localizations(context).paymentMethods),
          automaticallyImplyLeading: false,
        ),
        body: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: PadColumn(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            spacing: 16,
            children: [
              TextFormField(
                initialValue: widget.user.iban,
                decoration: inputDecoration(localizations(context).iban),
                enabled: !_loading,
                onChanged: (_) {
                  if (!_edited) setState(() => _edited = true);
                },
                onSaved: (iban) => _ibanValue = iban.toNullable(),
                focusNode: FocusNode(),
              ),
              TextFormField(
                initialValue: widget.user.payPal,
                decoration: inputDecoration(localizations(context).paypal),
                enabled: !_loading,
                onChanged: (_) {
                  if (!_edited) setState(() => _edited = true);
                },
                onSaved: (payPal) => _payPalValue = payPal.toNullable()?.split("/").last,
              ),
            ],
          ), //TODO: implement
        ),
        bottomNavigationBar: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Divider(height: 0),
              PadRow(
                spacing: 1,
                children: [
                  Expanded(child: ModalButton(onPressed: _discardChanges, child: Text(localizations(context).cancel))),
                  Expanded(child: ModalButton(onPressed: _edited ? _saveChanges : null, child: Text(localizations(context).saveChanges))),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
