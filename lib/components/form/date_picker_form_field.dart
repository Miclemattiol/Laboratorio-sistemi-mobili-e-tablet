import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart';

class DatePickerFormField extends StatelessWidget {
  final DateTime? initialValue;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final AutovalidateMode? autovalidateMode;
  final InputDecoration? decoration;
  final String? Function(DateTime? value)? validator;
  final void Function(DateTime? value)? onSaved;
  final void Function(DateTime value)? onChanged;
  final bool enabled;
  final bool pickDate;
  final bool pickTime;

  static final dateTimeFormat = DateFormat("dd/MM/yyyy HH:mm");
  static final dateFormat = DateFormat("dd/MM/yyyy");
  static final timeFormat = DateFormat("HH:mm");

  DatePickerFormField({
    this.initialValue,
    this.firstDate,
    this.lastDate,
    this.autovalidateMode,
    this.decoration,
    this.validator,
    this.onSaved,
    this.onChanged,
    this.enabled = true,
    super.key,
  })  : pickDate = true,
        pickTime = true,
        assert(firstDate == null || lastDate == null || !firstDate.isAfter(lastDate));

  const DatePickerFormField.dateOnly({
    this.initialValue,
    this.firstDate,
    this.lastDate,
    this.autovalidateMode,
    this.decoration,
    this.validator,
    this.onSaved,
    this.onChanged,
    this.enabled = true,
    super.key,
  })  : pickDate = true,
        pickTime = false;

  const DatePickerFormField.timeOnly({
    this.initialValue,
    this.autovalidateMode,
    this.decoration,
    this.validator,
    this.onSaved,
    this.onChanged,
    this.enabled = true,
    super.key,
  })  : pickDate = false,
        pickTime = true,
        firstDate = null,
        lastDate = null;

  void _pickDateTime(BuildContext context, FormFieldState<DateTime?> state) async {
    final initialDate = state.value ?? DateTime.now();
    final firstDate = this.firstDate ?? (this.lastDate != null ? DateTime(this.lastDate!.year - 100, this.lastDate!.month, this.lastDate!.day) : DateTime.now());
    final lastDate = this.lastDate ?? DateTime(firstDate.year + 100, firstDate.month, firstDate.day);

    DateTime? date = !pickDate
        ? DateTime(0)
        : await showDatePicker(
            context: context,
            initialDate: initialDate,
            firstDate: state.value?.isBefore(firstDate) == true ? state.value! : firstDate,
            lastDate: state.value?.isAfter(lastDate) == true ? state.value! : lastDate,
            locale: const Locale("it", "IT"),
          );
    if (date == null) return;
    TimeOfDay? time = await (() async => !pickTime || !context.mounted
        ? const TimeOfDay(hour: 0, minute: 0)
        : await showTimePicker(
            context: context,
            initialTime: TimeOfDay.fromDateTime(initialDate),
            builder: (context, child) {
              return Localizations(
                locale: const Locale("it", "IT"),
                delegates: GlobalMaterialLocalizations.delegates,
                child: child,
              );
            },
          ))();
    if (time == null) return;

    onChanged?.call(date);
    state.didChange(DateTime(date.year, date.month, date.day, time.hour, time.minute));
  }

  @override
  Widget build(BuildContext context) {
    return FormField<DateTime?>(
      initialValue: initialValue,
      autovalidateMode: autovalidateMode,
      validator: validator,
      onSaved: onSaved,
      enabled: enabled,
      builder: (state) {
        return GestureDetector(
          onTap: enabled ? () => _pickDateTime(context, state) : null,
          child: InputDecorator(
            decoration: (decoration ?? const InputDecoration()).copyWith(
              enabled: enabled,
              errorText: decoration?.errorText ?? state.errorText,
            ),
            isEmpty: state.value == null,
            child: Text(
              state.value != null ? "${pickDate ? DatePickerFormField.dateFormat.format(state.value!) : ""} ${pickTime ? DatePickerFormField.timeFormat.format(state.value!) : ""}".trim() : "",
              style: const TextStyle(fontSize: 16),
            ),
          ),
        );
      },
    );
  }
}
