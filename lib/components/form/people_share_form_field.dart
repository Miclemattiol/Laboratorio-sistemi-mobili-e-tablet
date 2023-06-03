import 'package:flutter/material.dart';
import 'package:house_wallet/data/house_data.dart';
import 'package:house_wallet/pages/shopping/people_share_dialog.dart';

class PeopleSharesFormField extends StatelessWidget {
  final HouseDataRef house;
  final Shares? initialValue;
  final AutovalidateMode? autovalidateMode;
  final InputDecoration? decoration;
  final String? Function(Shares value)? validator;
  final void Function(Shares value)? onSaved;
  final void Function(Shares value)? onChanged;
  final bool enabled;

  const PeopleSharesFormField({
    required this.house,
    this.initialValue,
    this.autovalidateMode,
    this.decoration,
    this.validator,
    this.onSaved,
    this.onChanged,
    this.enabled = true,
    super.key,
  });

  void _pickPeople(BuildContext context, FormFieldState<Shares?> state) async {
    final value = await showDialog<Shares>(
      context: context,
      builder: (_) => PeopleSharesDialog(house: house, initialValues: state.value),
    );
    if (value == null) return;

    onChanged?.call(value);
    state.didChange(value);
  }

  @override
  Widget build(BuildContext context) {
    return FormField<Shares>(
      initialValue: initialValue ?? {},
      autovalidateMode: autovalidateMode,
      validator: (value) => validator?.call(value ?? {}),
      onSaved: (newValue) => onSaved?.call(newValue ?? {}),
      enabled: enabled,
      builder: (state) {
        return GestureDetector(
          onTap: enabled ? () => _pickPeople(context, state) : null,
          child: InputDecorator(
            decoration: (decoration ?? const InputDecoration()).copyWith(
              enabled: enabled,
              errorText: decoration?.errorText ?? state.errorText,
            ),
            isEmpty: (state.value ?? {}).isEmpty,
            child: Text(
              (state.value ?? {}).isEmpty ? "" : state.value!.entries.map((entry) => "${house.getUser(entry.key).username} (${entry.value})").join(", "),
              style: const TextStyle(fontSize: 16),
            ),
          ),
        );
      },
    );
  }
}
