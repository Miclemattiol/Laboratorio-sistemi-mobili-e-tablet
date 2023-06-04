import 'package:flutter/material.dart';

class DropdownFormField<T> extends StatefulWidget {
  final Map<T, Widget> items;
  final T? initialValue;
  final AutovalidateMode? autovalidateMode;
  final InputDecoration? decoration;
  final TextStyle? style;
  final String? Function(T? value)? validator;
  final void Function(T? value)? onSaved;
  final void Function(T? value)? onChanged;
  final bool enabled;
  final Key? dropdownWidgetKey;

  const DropdownFormField({
    required this.items,
    this.initialValue,
    this.autovalidateMode,
    this.decoration,
    this.style,
    this.validator,
    this.onSaved,
    this.onChanged,
    this.enabled = true,
    this.dropdownWidgetKey,
    super.key,
  });

  @override
  State<DropdownFormField<T>> createState() => _DropdownFormFieldState<T>();
}

class _DropdownFormFieldState<T> extends State<DropdownFormField<T>> {
  late T? _value = widget.items.keys.contains(widget.initialValue) ? widget.initialValue : null;

  @override
  Widget build(BuildContext context) {
    return ExcludeFocus(
      excluding: true,
      child: DropdownButtonFormField<T>(
        key: widget.dropdownWidgetKey,
        value: _value,
        autovalidateMode: widget.autovalidateMode,
        decoration: (widget.decoration ?? const InputDecoration()).copyWith(enabled: widget.enabled),
        style: widget.style ?? Theme.of(context).textTheme.bodyMedium,
        validator: widget.validator,
        onSaved: widget.onSaved,
        onChanged: widget.enabled
            ? (value) {
                _value = value;
                widget.onChanged?.call(value);
              }
            : null,
        items: widget.items.entries.map((entry) => DropdownMenuItem(value: entry.key, child: entry.value)).toList(),
      ),
    );
  }
}
