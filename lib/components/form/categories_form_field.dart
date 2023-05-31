import 'package:flutter/material.dart';
import 'package:house_wallet/data/firestore.dart';
import 'package:house_wallet/data/payments/category.dart';
import 'package:house_wallet/pages/payments/categories/categories_dialog.dart';

class CategoriesFormField extends StatelessWidget {
  final List<FirestoreDocument<Category>> values;
  final Set<String>? initialValues;
  final AutovalidateMode? autovalidateMode;
  final InputDecoration? decoration;
  final String? Function(Set<String>? value)? validator;
  final void Function(Set<String>? value)? onSaved;
  final void Function(Set<String> value)? onChanged;
  final bool enabled;

  const CategoriesFormField({
    required this.values,
    this.initialValues,
    this.autovalidateMode,
    this.decoration,
    this.validator,
    this.onSaved,
    this.onChanged,
    this.enabled = true,
    super.key,
  });

  void _pickCategories(BuildContext context, FormFieldState<Set<String>> state) async {
    final categories = await showDialog<Set<String>>(context: context, builder: (context) => CategoriesDialog(categories: values, initialValues: state.value));
    if (categories == null) return;
    state.didChange(categories);
  }

  @override
  Widget build(BuildContext context) {
    final valuesMap = Map<String, Category>.fromEntries(values.map((category) => MapEntry(category.id, category.data)));
    return FormField<Set<String>>(
      initialValue: initialValues == null ? {} : Set.from(initialValues!.where((category) => valuesMap.containsKey(category))),
      autovalidateMode: autovalidateMode,
      validator: validator,
      onSaved: onSaved,
      enabled: enabled,
      builder: (state) => GestureDetector(
        onTap: () => _pickCategories(context, state),
        child: InputDecorator(
          decoration: (decoration ?? const InputDecoration()).copyWith(
            enabled: enabled,
            errorText: decoration?.errorText ?? state.errorText,
          ),
          isEmpty: state.value!.isEmpty,
          child: Text((state.value ?? {}).map((category) => valuesMap[category]!.name).join(", ")),
        ),
      ),
    );
  }
}
