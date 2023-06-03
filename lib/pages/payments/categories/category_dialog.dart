import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_series/flutter_series.dart';
import 'package:house_wallet/components/form/icon_form_field.dart';
import 'package:house_wallet/components/ui/custom_dialog.dart';
import 'package:house_wallet/components/ui/modal_button.dart';
import 'package:house_wallet/data/firestore.dart';
import 'package:house_wallet/data/house_data.dart';
import 'package:house_wallet/data/payments/category.dart';
import 'package:house_wallet/main.dart';
import 'package:house_wallet/pages/payments/payments_page.dart';
import 'package:house_wallet/themes.dart';
import 'package:house_wallet/utils.dart';

class CategoryDialog extends StatefulWidget {
  final HouseDataRef house;
  final FirestoreDocument<Category>? category;

  const CategoryDialog({
    required this.house,
    super.key,
  }) : category = null;

  const CategoryDialog.edit(
    FirestoreDocument<Category> this.category, {
    required this.house,
    super.key,
  });

  @override
  State<CategoryDialog> createState() => _CategoryDialogState();
}

class _CategoryDialogState extends State<CategoryDialog> {
  final _formKey = GlobalKey<FormState>();
  bool _loading = false;

  IconData? _iconValue;
  String? _nameValue;

  void _saveItem() async {
    final navigator = Navigator.of(context);

    _formKey.currentState!.save();
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    try {
      if ((await PaymentsPage.categoriesFirestoreRef(widget.house.id).where(Category.iconKey, isEqualTo: _iconValue!.codePoint).where(Category.nameKey, isEqualTo: _nameValue).count().get()).count != 0) {
        throw FirebaseException(plugin: "", message: "duplicate");
      }

      if (widget.category == null) {
        final ref = await PaymentsPage.categoriesFirestoreRef(widget.house.id).add(Category(
          icon: _iconValue!,
          name: _nameValue!,
        ));

        navigator.pop<String>(ref.id);
      } else {
        await widget.category!.reference.update({
          Category.iconKey: _iconValue!.codePoint,
          Category.nameKey: _nameValue!,
        });

        navigator.pop();
      }
    } on FirebaseException catch (error) {
      if (!context.mounted) return;
      CustomDialog.alert(
        context: context,
        title: localizations(context).error,
        content: localizations(context).saveChangesError(error.message.toString()),
      );
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: CustomDialog(
        dismissible: false,
        padding: const EdgeInsets.all(24),
        crossAxisAlignment: CrossAxisAlignment.center,
        body: [
          PadRow(
            spacing: 8,
            children: [
              SizedBox(
                width: 48,
                child: IconFormField(
                  enabled: !_loading,
                  initialValue: widget.category?.data.icon,
                  decoration: inputDecoration(),
                  onSaved: (icon) => _iconValue = icon,
                ),
              ),
              Expanded(
                child: TextFormField(
                  enabled: !_loading,
                  autofocus: widget.category?.data.name == null,
                  initialValue: widget.category?.data.name,
                  decoration: inputDecoration(localizations(context).name, true),
                  onSaved: (name) => _nameValue = name.toNullable(),
                  validator: (value) => value?.trim().isEmpty == true ? localizations(context).nameMissing : null,
                ),
              ),
            ],
          ),
        ],
        actions: [
          ModalButton(enabled: !_loading, onPressed: () => Navigator.of(context).pop(), child: Text(localizations(context).cancel)),
          ModalButton(enabled: !_loading, onPressed: _saveItem, child: Text(localizations(context).ok)),
        ],
      ),
    );
  }
}
