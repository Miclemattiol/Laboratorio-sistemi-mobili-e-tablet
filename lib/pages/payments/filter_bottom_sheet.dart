import 'package:flutter/material.dart';
import 'package:house_wallet/components/ui/custom_bottom_sheet.dart';
import 'package:house_wallet/components/ui/modal_button.dart';
import 'package:house_wallet/main.dart';

//TODO filter
class FilterBottomSheet extends StatelessWidget {
  const FilterBottomSheet({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return CustomBottomSheet(
      body: const [
        Text("TODO")
      ],
      actions: [
        ModalButton(onPressed: () => Navigator.of(context).pop(), child: Text(localizations(context).buttonCancel)),
        ModalButton(onPressed: () => Navigator.of(context).pop(), child: Text(localizations(context).buttonOk)),
      ],
    );
  }
}
