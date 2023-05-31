import 'package:flutter/material.dart';
import 'package:flutter_series/flutter_series.dart';
import 'package:house_wallet/data/firestore.dart';
import 'package:house_wallet/data/payments/category.dart';
import 'package:house_wallet/main.dart';

class CategoryFormField extends StatelessWidget {
  final List<FirestoreDocument<Category>> categories;
  final FirestoreDocument<Category>? initialValue;
  final AutovalidateMode? autovalidateMode;
  final InputDecoration? decoration;
  final String? Function(String? value)? validator;
  final void Function(String? value)? onSaved;
  final void Function(String? value)? onChanged;
  final bool enabled;

  const CategoryFormField({
    required this.categories,
    this.initialValue,
    this.autovalidateMode,
    this.decoration,
    this.validator,
    this.onSaved,
    this.onChanged,
    this.enabled = true,
    super.key,
  });

  static const noCategoryKey = "no_category";
  static const newCategoryKey = "new_category";

  String? _getInitialValue() {
    if (initialValue == null) return null;
    final selectedId = initialValue!.id;
    return categories.where((category) => category.id == selectedId).isEmpty ? null : selectedId;
  }

  @override
  Widget build(BuildContext context) {
    return FormField<String>(
      initialValue: _getInitialValue(),
      autovalidateMode: autovalidateMode,
      validator: validator,
      onSaved: onSaved,
      enabled: enabled,
      builder: (state) => InputDecorator(
        decoration: (decoration ?? const InputDecoration()).copyWith(
          contentPadding: const EdgeInsets.symmetric(horizontal: 12),
          enabled: enabled,
          errorText: decoration?.errorText ?? state.errorText,
        ),
        isEmpty: state.value == null,
        child: DropdownButton<String>(
          value: state.value,
          isExpanded: true,
          underline: const SizedBox.shrink(),
          style: Theme.of(context).textTheme.bodyMedium,
          items: [
            DropdownMenuItem(
              value: noCategoryKey,
              child: PadRow(
                spacing: 4,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(localizations(context).paymentCategoryEmpty, style: const TextStyle(fontStyle: FontStyle.italic)),
                ],
              ),
            ),
            DropdownMenuItem(
              value: newCategoryKey,
              child: PadRow(
                spacing: 4,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Icon(Icons.add),
                  Text(localizations(context).paymentCategoryNew, style: const TextStyle(fontStyle: FontStyle.italic)),
                ],
              ),
            ),
            ...categories.map((category) {
              return DropdownMenuItem(
                value: category.id,
                child: PadRow(
                  spacing: 4,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(category.data.icon, color: enabled ? null : Theme.of(context).disabledColor),
                    Text(category.data.name),
                  ],
                ),
              );
            })
          ],
          onChanged: enabled
              ? (value) {
                  final newValue = value == noCategoryKey ? null : value;
                  state.didChange(newValue);
                  onChanged?.call(newValue!);
                }
              : null,
        ),
      ),
    );
  }
}
