import 'package:flutter/material.dart';
import 'package:house_wallet/data/house_data.dart';
import 'package:house_wallet/pages/shopping/people_dialog.dart';

class PeopleFormField extends StatelessWidget {
  final HouseDataRef house;
  final Set<String>? initialValue;
  final AutovalidateMode? autovalidateMode;
  final InputDecoration? decoration;
  final String? Function(Set<String> value)? validator;
  final void Function(Set<String> value)? onSaved;
  final void Function(Set<String> value)? onChanged;
  final bool enabled;

  const PeopleFormField({
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

  void _pickPeople(BuildContext context, FormFieldState<Set<String>?> state) async {
    final value = await showDialog<Set<String>>(
      context: context,
      builder: (_) => PeopleDialog(house: house, initialValue: state.value),
    );
    if (value == null) return;

    onChanged?.call(value);
    state.didChange(value);
  }

  @override
  Widget build(BuildContext context) {
    return FormField<Set<String>>(
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
              (state.value ?? {}).isEmpty ? "" : state.value!.map((user) => house.getUser(user).username).join(", "),
              style: const TextStyle(fontSize: 16),
            ),
          ),
        );
      },
    );
  }
}
