import 'package:flutter/material.dart';
import 'package:flutter_series/flutter_series.dart';
import 'package:house_wallet/components/form/number_form_field.dart';
import 'package:house_wallet/components/ui/custom_bottom_sheet.dart';
import 'package:house_wallet/components/ui/modal_button.dart';
import 'package:house_wallet/main.dart';
import 'package:house_wallet/themes.dart';

class TransactionDetailsBottomSheet extends StatelessWidget {
  const TransactionDetailsBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomBottomSheet(
      spacing: 16,
      body: [
        PadRow(
          spacing: 16,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const SizedBox(width: 64, height: 64, child: Placeholder()),
            Expanded(
              child: TextFormField(
                decoration: inputDecoration(localizations(context).title),
              ),
            ),
            SizedBox(
              width: 100,
              child: NumberFormField(
                decoration: inputDecoration(localizations(context).price),
                decimal: true,
              ),
            ),
          ],
        ),
        TextFormField(
          decoration: inputDecoration("TODO"),
        ),
        TextFormField(
          decoration: inputDecoration("TODO"),
        ),
        TextFormField(
          decoration: inputDecoration("TODO"),
        ),
      ],
      actions: [
        ModalButton(onPressed: () => Navigator.of(context).pop(), child: Text(localizations(context).buttonCancel)),
        ModalButton(onPressed: () {}, child: Text(localizations(context).buttonOk)),
      ],
    );
  }
}
