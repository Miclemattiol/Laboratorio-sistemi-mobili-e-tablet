import 'package:flutter/material.dart';
import 'package:house_wallet/components/form/number_form_field.dart';
import 'package:house_wallet/components/ui/custom_dialog.dart';
import 'package:house_wallet/components/ui/modal_button.dart';
import 'package:house_wallet/main.dart';
import 'package:house_wallet/themes.dart';

class PriceQuantity {
  final num? price;
  final int? quantity;

  const PriceQuantity(this.price, this.quantity);

  String? label(BuildContext context) {
    if (price != null) {
      return "${quantity ?? 1} x ${currencyFormat(context).format(price)}";
    }

    if (quantity != null) {
      return "${quantity ?? 1}x";
    }

    return null;
  }
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
  final _formKey = GlobalKey<FormState>();

  int? _quantityValue;
  num? _priceValue;

  void _returnValue() {
    _formKey.currentState!.save();
    if (!_formKey.currentState!.validate()) return;

    Navigator.of(context).pop<PriceQuantity?>(PriceQuantity(
      _priceValue,
      _quantityValue,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: CustomDialog(
        dismissible: false,
        spacing: 16,
        padding: const EdgeInsets.all(24),
        crossAxisAlignment: CrossAxisAlignment.center,
        body: [
          NumberFormField<int>(
            initialValue: widget.initialValue?.quantity,
            decoration: inputDecoration(localizations(context).quantity),
            validator: (quantity) => quantity == 0 ? localizations(context).quantityInvalid : null,
            onSaved: (quantity) => _quantityValue = quantity,
          ),
          NumberFormField(
            initialValue: widget.initialValue?.price,
            decimal: true,
            decoration: inputDecoration(localizations(context).price),
            onSaved: (price) => _priceValue = price,
          ),
        ],
        actions: [
          ModalButton(onPressed: () => Navigator.of(context).pop<String?>(), child: Text(localizations(context).cancel)),
          ModalButton(onPressed: _returnValue, child: Text(localizations(context).ok)),
        ],
      ),
    );
  }
}
