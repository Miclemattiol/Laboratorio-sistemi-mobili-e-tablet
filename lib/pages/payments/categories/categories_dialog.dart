import 'package:flutter/material.dart';
import 'package:flutter_series/flutter_series.dart';
import 'package:house_wallet/components/ui/custom_dialog.dart';
import 'package:house_wallet/components/ui/modal_button.dart';
import 'package:house_wallet/data/firestore.dart';
import 'package:house_wallet/data/payments/category.dart';
import 'package:house_wallet/main.dart';

class CategoriesDialog extends StatefulWidget {
  final Set<String>? initialValues;
  final List<FirestoreDocument<Category>> categories;

  const CategoriesDialog({
    this.initialValues,
    required this.categories,
    super.key,
  });

  @override
  State<CategoriesDialog> createState() => _CategoriesDialogState();
}

class _CategoriesDialogState extends State<CategoriesDialog> {
  late final Set<String> _values = Set.from(widget.initialValues ?? {});

  @override
  Widget build(BuildContext context) {
    return CustomDialog(
      dismissible: false,
      padding: const EdgeInsets.all(24),
      crossAxisAlignment: CrossAxisAlignment.center,
      body: widget.categories.map((category) {
        return CheckboxListTile(
          value: _values.contains(category.id),
          contentPadding: EdgeInsets.zero,
          onChanged: (value) => setState(() {
            if (_values.contains(category.id)) {
              _values.remove(category.id);
            } else {
              _values.add(category.id);
            }
          }),
          title: PadRow(
            spacing: 4,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(category.data.icon),
              Text(category.data.name),
            ],
          ),
        );
      }).toList(),
      actions: [
        ModalButton(onPressed: () => Navigator.of(context).pop<Set<String>>(), child: Text(localizations(context).buttonCancel)),
        ModalButton(onPressed: () => Navigator.of(context).pop<Set<String>>(_values), child: Text(localizations(context).buttonOk)),
      ],
    );
  }
}
