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
  late String? _supermarketValue = widget.initialValue;

  @override
  Widget build(BuildContext context) {
    return CustomDialog(
      dismissible: false,
      padding: const EdgeInsets.all(24),
      crossAxisAlignment: CrossAxisAlignment.center,
      body: [
        TextFormField(
          autofocus: true,
          initialValue: widget.initialValue,
          decoration: inputDecoration(localizations(context).supermarket),
          onChanged: (value) => _supermarketValue = value.trim(),
        ),
      ],
      actions: [
        ModalButton(onPressed: () => Navigator.of(context).pop<String?>(), child: Text(localizations(context).cancel)),
        ModalButton(onPressed: () => Navigator.of(context).pop<String?>(_supermarketValue), child: Text(localizations(context).ok)),
      ],
    );
  }
}
