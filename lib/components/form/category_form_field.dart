import 'package:flutter/material.dart';
import 'package:flutter_series/flutter_series.dart';
import 'package:house_wallet/components/form/dropdown_form_field.dart';
import 'package:house_wallet/data/firestore.dart';
import 'package:house_wallet/data/house_data.dart';
import 'package:house_wallet/data/payments/category.dart';
import 'package:house_wallet/main.dart';
import 'package:house_wallet/pages/payments/categories/category_dialog.dart';

class CategoryFormField extends StatefulWidget {
  final List<FirestoreDocument<Category>> categories;
  final FirestoreDocument<Category>? initialValue;
  final AutovalidateMode? autovalidateMode;
  final InputDecoration? decoration;
  final TextStyle? style;
  final HouseDataRef house;
  final String? Function(String? value)? validator;
  final void Function(String? value)? onSaved;
  final void Function(String? value)? onChanged;
  final bool enabled;

  const CategoryFormField({
    required this.categories,
    required this.house,
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

  @override
  State<CategoryFormField> createState() => _CategoryFormFieldState();
}

class _CategoryFormFieldState extends State<CategoryFormField> {
  Widget _buildItem(BuildContext context, {IconData? icon, required Text text}) {
    return PadRow(
      spacing: 16,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (icon != null) Icon(icon, color: widget.enabled ? null : Theme.of(context).disabledColor),
        text,
      ],
    );
  }

  final dropdownFormField = GlobalKey<FormFieldState>();
  @override
  Widget build(BuildContext context) {
    return DropdownFormField<String>(
      dropdownWidgetKey: dropdownFormField,
      initialValue: widget.initialValue?.id,
      autovalidateMode: widget.autovalidateMode,
      decoration: widget.decoration,
      style: widget.style,
      validator: widget.validator,
      onSaved: widget.onSaved,
      onChanged: (value) async {
        if (value == CategoryFormField.noCategoryKey) return dropdownFormField.currentState!.didChange(null);
        if (value == CategoryFormField.newCategoryKey) {
          value = await showDialog<String?>(context: context, builder: (context) => CategoryDialog(house: widget.house));
          dropdownFormField.currentState!.didChange(value ?? CategoryFormField.noCategoryKey);
        }
        widget.onChanged?.call(value);
      },
      enabled: widget.enabled,
      items: Map.fromEntries([
        MapEntry(CategoryFormField.noCategoryKey, _buildItem(context, text: Text(localizations(context).noCategory, style: const TextStyle(fontStyle: FontStyle.italic)))),
        MapEntry(CategoryFormField.newCategoryKey, _buildItem(context, icon: Icons.add, text: Text(localizations(context).newCategory, style: const TextStyle(fontStyle: FontStyle.italic)))),
        ...widget.categories.map((category) => MapEntry(category.id, _buildItem(context, icon: category.data.icon, text: Text(category.data.name)))),
      ]),
    );
  }
}
