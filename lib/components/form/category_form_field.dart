import 'package:flutter/material.dart';
import 'package:flutter_series/flutter_series.dart';
import 'package:house_wallet/components/form/dropdown_form_field.dart';
import 'package:house_wallet/data/firestore.dart';
import 'package:house_wallet/data/payments/category.dart';
import 'package:house_wallet/main.dart';

class CategoryFormField extends StatelessWidget {
  final List<FirestoreDocument<Category>> categories;
  final FirestoreDocument<Category>? initialValue;
  final AutovalidateMode? autovalidateMode;
  final InputDecoration? decoration;
  final TextStyle? style;
  final String? Function(String? value)? validator;
  final void Function(String? value)? onSaved;
  final void Function(String? value)? onChanged;
  final bool enabled;

  const CategoryFormField({
    required this.categories,
    this.initialValue,
    this.autovalidateMode,
    this.decoration,
    this.style,
    this.validator,
    this.onSaved,
    this.onChanged,
    this.enabled = true,
    super.key,
  });

  static const noCategoryKey = "no_category";
  static const newCategoryKey = "new_category";

  Widget _buildItem(BuildContext context, {IconData? icon, required Text text}) {
    return PadRow(
      spacing: 16,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (icon != null) Icon(icon, color: enabled ? null : Theme.of(context).disabledColor),
        text,
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final dropdownFormField = GlobalKey<FormFieldState>();
    return DropdownFormField<String>(
      dropdownWidgetKey: dropdownFormField,
      initialValue: initialValue?.id,
      autovalidateMode: autovalidateMode,
      decoration: decoration,
      style: style,
      validator: validator,
      onSaved: onSaved,
      onChanged: (value) {
        if (value == noCategoryKey) return dropdownFormField.currentState!.didChange(null);
        onChanged?.call(value);
      },
      enabled: enabled,
      items: Map.fromEntries([
        MapEntry(noCategoryKey, _buildItem(context, text: Text(localizations(context).noCategory, style: const TextStyle(fontStyle: FontStyle.italic)))),
        MapEntry(newCategoryKey, _buildItem(context, icon: Icons.add, text: Text(localizations(context).newCategory, style: const TextStyle(fontStyle: FontStyle.italic)))),
        ...categories.map((category) => MapEntry(category.id, _buildItem(context, icon: category.data.icon, text: Text(category.data.name)))),
      ]),
    );
  }
}
