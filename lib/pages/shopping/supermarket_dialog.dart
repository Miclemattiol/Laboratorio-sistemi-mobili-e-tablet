import 'package:flutter/material.dart';
import 'package:house_wallet/components/ui/custom_dialog.dart';
import 'package:house_wallet/components/ui/modal_button.dart';
import 'package:house_wallet/main.dart';
import 'package:house_wallet/themes.dart';

class SupermarketDialog extends StatefulWidget {
  final String? initialValue;

  const SupermarketDialog({
    required this.initialValue,
    super.key,
  });

  @override
  State<SupermarketDialog> createState() => _SupermarketDialogState();
}

class _SupermarketDialogState extends State<SupermarketDialog> {
  GlobalKey<FormState> formKey = GlobalKey();

  String? _supermarketValue;

  @override
  Widget build(BuildContext context) {
    void submit() {
      formKey.currentState!.save();
      Navigator.of(context).pop<String?>(_supermarketValue);
    }

    return Form(
      key: formKey,
      child: CustomDialog(
        dismissible: false,
        padding: const EdgeInsets.all(24),
        crossAxisAlignment: CrossAxisAlignment.center,
        body: [
          TextFormField(
            autofocus: true,
            initialValue: widget.initialValue,
            decoration: inputDecoration(localizations(context).supermarketChipTooltip),
            onSaved: (newValue) => _supermarketValue = newValue?.trim(),
          ),
        ],
        actions: [
          ModalButton(onPressed: () => Navigator.of(context).pop<String?>(), child: Text(localizations(context).buttonCancel)),
          ModalButton(onPressed: submit, child: Text(localizations(context).buttonOk)),
        ],
      ),
    );
  }
}
