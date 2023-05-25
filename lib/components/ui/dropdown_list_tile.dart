import 'package:flutter/material.dart';

class DropdownListTile<T> extends StatefulWidget {
  final List<DropdownMenuItem<T>> values;
  final T? initialValue;
  final Widget? title;
  final void Function(T? value)? onChanged;

  const DropdownListTile({
    required this.values,
    this.initialValue,
    this.title,
    this.onChanged,
    super.key,
  });

  @override
  State<DropdownListTile> createState() => _DropdownListTileState<T>();
}

class _DropdownListTileState<T> extends State<DropdownListTile<T>> {
  late T? _value = widget.initialValue;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: widget.title,
      trailing: DropdownButton<T>(
        value: _value,
        items: widget.values,
        onChanged: (value) {
          setState(() => _value = value);
          widget.onChanged?.call(value);
        },
      ),
    );
  }
}
