import 'package:flutter/material.dart';
import 'package:flutter_series/flutter_series.dart';
import 'package:house_wallet/components/ui/custom_bottom_sheet.dart';
import 'package:house_wallet/components/ui/modal_button.dart';
import 'package:house_wallet/main.dart';
import 'package:house_wallet/themes.dart';

class PaymentDetailsBottomSheet extends StatelessWidget {
  const PaymentDetailsBottomSheet({super.key});

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
          decoration: inputDecoration("TODO"),
        ),
        TextFormField(
          decoration: inputDecoration("TODO"),
        ),
        ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 250.0),
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            reverse: true,
            child: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: TextFormField(
                decoration: InputDecoration(border: const OutlineInputBorder(), labelText: localizations(context).descriptionInput), //TODO modificare la funzione per lo stile e aggiungere localizations
                keyboardType: TextInputType.multiline,
                maxLines: null,
                minLines: 1,
              ),
            ),
          ),
        ),
      ],
      actions: [
        ModalButton(onPressed: () => Navigator.of(context).pop(), child: Text(localizations(context).buttonCancel)),
        ModalButton(onPressed: () {}, child: Text(localizations(context).buttonOk)),
      ],
    );
  }
}
