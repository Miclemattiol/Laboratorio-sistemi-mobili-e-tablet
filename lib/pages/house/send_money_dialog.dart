import 'package:flutter/material.dart';
import 'package:house_wallet/components/ui/custom_dialog.dart';
import 'package:house_wallet/components/ui/modal_button.dart';
import 'package:house_wallet/data/user.dart';
import 'package:house_wallet/main.dart';

//TODO
class SendMoneyDialog extends StatelessWidget {
  final User user;

  const SendMoneyDialog(
    this.user, {
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return CustomDialog(
      body: [
        TextFormField(
          decoration: InputDecoration(border: const OutlineInputBorder(), labelText: localizations(context).price),
        ),
        TextFormField(
          decoration: InputDecoration(border: const OutlineInputBorder(), labelText: localizations(context).ibanInput),
        ),
        ElevatedButton(onPressed: () {}, child: const Text("Paga con PayPal")),
      ],
      actions: [
        ModalButton(onPressed: () => Navigator.of(context).pop(), child: Text(localizations(context).buttonCancel)),
        ModalButton(onPressed: () => Navigator.of(context).pop(), child: Text(localizations(context).buttonPay)),
      ],
    );
  }
}
