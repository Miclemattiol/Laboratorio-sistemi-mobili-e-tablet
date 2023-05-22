import 'package:flutter/material.dart';
import 'package:flutter_series/flutter_series.dart';
import 'package:house_wallet/components/ui/custom_bottom_sheet.dart';
import 'package:house_wallet/components/ui/modal_button.dart';
import 'package:house_wallet/main.dart';

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
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  labelText: localizations(context).title,
                ),
              ),
            ),
            SizedBox(
              width: 100,
              child: TextFormField(
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  labelText: localizations(context).price,
                ),
              ),
            ),
          ],
        ),
        TextFormField(
          decoration: const InputDecoration(border: OutlineInputBorder(), labelText: "TODO"),
        ),
        TextFormField(
          decoration: const InputDecoration(border: OutlineInputBorder(), labelText: "TODO"),
        ),
        TextFormField(
          decoration: const InputDecoration(border: OutlineInputBorder(), labelText: "TODO"),
        ),
      ],
      actions: [
        ModalButton(onPressed: () => Navigator.of(context).pop(), child: Text(localizations(context).buttonCancel)),
        ModalButton(onPressed: () {}, child: Text(localizations(context).buttonOk)),
      ],
    );
  }
}
