import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class NumberFormField<T extends num> extends StatelessWidget {
  final TextEditingController? controller;
  final bool autofocus;
  final T? initialValue;
  final AutovalidateMode? autovalidateMode;
  final InputDecoration? decoration;
  final String? Function(T? value)? validator;
  final void Function(T? value)? onSaved;
  final void Function(T? value)? onChanged;
  final TextAlign textAlign;
  final bool enabled;
  final bool signed;
  final bool decimal;

  const NumberFormField({
    this.controller,
    this.autofocus = false,
    this.initialValue,
    this.autovalidateMode,
    this.decoration,
    this.validator,
    this.onSaved,
    this.onChanged,
    this.textAlign = TextAlign.start,
    this.enabled = true,
    this.signed = false,
    this.decimal = false,
    super.key,
  });

  TextInputFormatter getFormatter() {
    if (signed) {
      if (decimal) {
        return FilteringTextInputFormatter.allow(RegExp(r"^-?\d*(\.|,)?\d{0,2}"));
      } else {
        return FilteringTextInputFormatter.allow(RegExp(r"^-?\d*"));
      }
    } else {
      if (decimal) {
        return FilteringTextInputFormatter.allow(RegExp(r"^\d*(\.|,)?\d{0,2}"));
      } else {
        return FilteringTextInputFormatter.allow(RegExp(r"^\d*"));
      }
    }
  }

  T? _tryParse(String? str) {
    num? value = num.tryParse(str?.replaceAll(",", ".") ?? "");

    switch (T) {
      case int:
        return value?.toInt() as T?;
      case double:
        return value?.toDouble() as T?;
      default:
        return value as T?;
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      autofocus: autofocus,
      initialValue: initialValue?.toString(),
      autovalidateMode: autovalidateMode,
      decoration: decoration,
      validator: (value) => validator?.call(_tryParse(value)),
      onSaved: (value) => onSaved?.call(_tryParse(value)),
      onChanged: (value) => onChanged?.call(_tryParse(value)),
      textAlign: textAlign,
      enabled: enabled,
      keyboardType: TextInputType.numberWithOptions(signed: signed, decimal: decimal),
      inputFormatters: [
        getFormatter()
      ],
    );
  }
}
