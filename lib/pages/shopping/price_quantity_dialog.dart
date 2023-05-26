import 'package:flutter/material.dart';
import 'package:flutter_series/flutter_series.dart';
import 'package:house_wallet/components/form/number_form_field.dart';
import 'package:house_wallet/components/ui/custom_dialog.dart';
import 'package:house_wallet/components/ui/modal_button.dart';
import 'package:house_wallet/main.dart';
import 'package:house_wallet/themes.dart';

class PriceQuantity {
  final num? price;
  final int? quantity;

  const PriceQuantity(this.price, this.quantity);
}

class PriceQuantityDialog extends StatefulWidget {
  final PriceQuantity? initialValue;

  const PriceQuantityDialog({
    required this.initialValue,
    super.key,
  });

  @override
  State<PriceQuantityDialog> createState() => _PriceQuantityDialogState();
}

class _PriceQuantityDialogState extends State<PriceQuantityDialog> {
  GlobalKey<FormState> formKey = GlobalKey();

  num? _priceValue;
  int? _quantityValue;

  @override
  Widget build(BuildContext context) {
    void submit() {
      formKey.currentState!.save();
      Navigator.of(context).pop<PriceQuantity?>(PriceQuantity(_priceValue, _quantityValue));
    }

    return Form(
      key: formKey,
      child: CustomDialog(
        dismissible: false,
        padding: const EdgeInsets.all(24),
        crossAxisAlignment: CrossAxisAlignment.center,
        body: [
          PadRow(
            spacing: 16,
            children: [
              Expanded(
                child: NumberFormField<num>(
                  initialValue: widget.initialValue?.price,
                  decimal: true,
                  decoration: inputDecoration(localizations(context).price),
                  onSaved: (newValue) => _priceValue = newValue,
                ),
              ),
              Expanded(
                child: NumberFormField<int>(
                  initialValue: widget.initialValue?.quantity,
                  decoration: inputDecoration(localizations(context).quantity),
                  onSaved: (newValue) => _quantityValue = newValue,
                ),
              ),
            ],
          )
        ],
        actions: [
          ModalButton(onPressed: () => Navigator.of(context).pop<String?>(), child: Text(localizations(context).buttonCancel)),
          ModalButton(onPressed: submit, child: Text(localizations(context).buttonOk)),
        ],
      ),
    );
  }
}
