import 'package:flutter/material.dart';
import 'package:house_wallet/components/icon_picker.dart';

class IconFormField extends StatelessWidget {
  final IconData? initialValue;
  final AutovalidateMode? autovalidateMode;
  final InputDecoration? decoration;
  final String? Function(IconData? value)? validator;
  final void Function(IconData? value)? onSaved;
  final void Function(IconData value)? onChanged;
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

  void _pickIcon(BuildContext context, FormFieldState<IconData> state) async {
    final icon = await IconPicker.pickIcon(context);
    if (icon == null) return;
    state.didChange(icon);
  }

  @override
  Widget build(BuildContext context) {
    return FormField<IconData>(
      initialValue: initialValue ?? Icons.shopping_cart,
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
            child: Icon(state.value!),
          ),
        );
      },
    );
  }
}
