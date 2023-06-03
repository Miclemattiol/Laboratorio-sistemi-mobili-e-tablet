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
  late num? _priceValue = widget.initialValue?.price;
  late int? _quantityValue = widget.initialValue?.quantity;

  @override
  Widget build(BuildContext context) {
    return CustomDialog(
      dismissible: false,
      padding: const EdgeInsets.all(24),
      crossAxisAlignment: CrossAxisAlignment.center,
      body: [
        PadRow(
          spacing: 16,
          children: [
            Expanded(
              child: NumberFormField<int>(
                initialValue: widget.initialValue?.quantity,
                decoration: inputDecoration(localizations(context).quantity),
                onChanged: (value) => _quantityValue = value,
              ),
            ),
            Expanded(
              child: NumberFormField(
                initialValue: widget.initialValue?.price,
                decimal: true,
                decoration: inputDecoration(localizations(context).price),
                onChanged: (value) => _priceValue = value,
              ),
            ),
          ],
        )
      ],
      actions: [
        ModalButton(onPressed: () => Navigator.of(context).pop<String?>(), child: Text(localizations(context).cancel)),
        ModalButton(onPressed: () => Navigator.of(context).pop<PriceQuantity?>(PriceQuantity(_priceValue, _quantityValue)), child: Text(localizations(context).ok)),
      ],
    );
  }
}
