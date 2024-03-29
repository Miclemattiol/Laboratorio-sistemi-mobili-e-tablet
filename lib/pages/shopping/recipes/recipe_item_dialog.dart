import 'package:flutter/material.dart';
import 'package:house_wallet/components/form/number_form_field.dart';
import 'package:house_wallet/components/ui/custom_dialog.dart';
import 'package:house_wallet/components/ui/modal_button.dart';
import 'package:house_wallet/data/shopping/recipe.dart';
import 'package:house_wallet/main.dart';
import 'package:house_wallet/themes.dart';
import 'package:house_wallet/utils.dart';

class RecipeItemDialog extends StatefulWidget {
  final RecipeItem? initialValue;

  const RecipeItemDialog({
    this.initialValue,
    super.key,
  });

  @override
  State<RecipeItemDialog> createState() => _RecipeItemDialogState();
}

class _RecipeItemDialogState extends State<RecipeItemDialog> {
  final _formKey = GlobalKey<FormState>();
  late final users = [];

  String? _titleValue;
  num? _priceValue;

  void _saveItem() {
    _formKey.currentState!.save();
    if (!_formKey.currentState!.validate()) return;

    Navigator.of(context).pop<RecipeItem?>(RecipeItem(
      title: _titleValue!,
      price: _priceValue,
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
          TextFormField(
            autofocus: widget.initialValue?.title == null,
            initialValue: widget.initialValue?.title,
            decoration: inputDecoration(localizations(context).title, true),
            onSaved: (title) => _titleValue = title.toNullable(),
            validator: (value) => value?.trim().isEmpty == true ? localizations(context).titleMissing : null,
          ),
          NumberFormField(
            initialValue: widget.initialValue?.price,
            decoration: inputDecoration(localizations(context).price),
            decimal: true,
            onSaved: (price) => _priceValue = price,
          ),
        ],
        actions: [
          ModalButton(onPressed: () => Navigator.of(context).pop<RecipeItem?>(), child: Text(localizations(context).cancel)),
          ModalButton(onPressed: _saveItem, child: Text(localizations(context).ok)),
        ],
      ),
    );
  }
}
