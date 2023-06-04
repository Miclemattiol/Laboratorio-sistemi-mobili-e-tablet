import 'package:flutter/material.dart';
import 'package:house_wallet/components/icon_picker.dart';
import 'package:house_wallet/data/icons.dart';

class IconFormField extends StatelessWidget {
  final String? initialValue;
  final AutovalidateMode? autovalidateMode;
  final InputDecoration? decoration;
  final String? Function(String? value)? validator;
  final void Function(String? value)? onSaved;
  final void Function(String value)? onChanged;
  final bool enabled;

  const IconFormField({
    this.initialValue,
    this.autovalidateMode,
    this.decoration,
    this.validator,
    this.onSaved,
    this.onChanged,
    this.enabled = true,
    super.key,
  });

  void _pickIcon(BuildContext context, FormFieldState<String> state) async {
    final icon = await IconPicker.pickIcon(context);
    if (icon == null) return;
    state.didChange(icon);
  }

  @override
  Widget build(BuildContext context) {
    return FormField<String>(
      initialValue: initialValue ?? "shopping_cart",
      autovalidateMode: autovalidateMode,
      validator: (value) => validator?.call(value),
      onSaved: (newValue) => onSaved?.call(newValue),
      enabled: enabled,
      builder: (state) {
        return GestureDetector(
          onTap: enabled ? () => _pickIcon(context, state) : null,
          child: InputDecorator(
            decoration: (decoration ?? const InputDecoration()).copyWith(
              enabled: enabled,
              errorText: decoration?.errorText ?? state.errorText,
            ),
            child: Icon(icons[state.value], color: enabled ? null : Theme.of(context).disabledColor),
          ),
        );
      },
    );
  }
}
