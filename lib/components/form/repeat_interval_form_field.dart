import 'package:flutter/material.dart';
import 'package:house_wallet/components/form/number_form_field.dart';
import 'package:house_wallet/components/ui/collapsible_container.dart';
import 'package:house_wallet/data/tasks/task.dart';
import 'package:house_wallet/main.dart';

class RepeatData {
  final RepeatOptions? repeat;
  final int? interval;

  const RepeatData(this.repeat, this.interval);
}

class RepeatIntervalFormField extends StatefulWidget {
  final RepeatData? initialValues;
  final AutovalidateMode? autovalidateMode;
  final InputDecoration? intervalInputDecoration;
  final String? Function(RepeatData? value)? validator;
  final void Function(RepeatData? value)? onSaved;
  final void Function(RepeatData value)? onChanged;
  final bool enabled;

  const RepeatIntervalFormField({
    this.initialValues,
    this.autovalidateMode,
    this.intervalInputDecoration,
    this.validator,
    this.onSaved,
    this.onChanged,
    this.enabled = true,
    super.key,
  });

  @override
  State<RepeatIntervalFormField> createState() => _RepeatIntervalFormFieldState();
}

class _RepeatIntervalFormFieldState extends State<RepeatIntervalFormField> {
  late RepeatOptions _repeatValue = widget.initialValues?.repeat ?? RepeatOptions.daily;
  late int? _intervalValue = widget.initialValues?.interval;

  @override
  Widget build(BuildContext context) {
    return FormField<RepeatData>(
      initialValue: widget.initialValues ?? const RepeatData(null, null),
      autovalidateMode: widget.autovalidateMode,
      validator: widget.validator,
      onSaved: widget.onSaved,
      enabled: widget.enabled,
      builder: (state) {
        final stateValue = state.value!;
        final isRepeat = stateValue.repeat != null;
        widget.onChanged?.call(stateValue);
        return InputDecorator(
          decoration: InputDecoration(
            border: InputBorder.none,
            contentPadding: EdgeInsets.zero,
            errorText: state.errorText,
          ),
          child: Column(
            children: [
              SwitchListTile(
                value: isRepeat,
                title: Text(localizations(context).taskRepeat),
                contentPadding: EdgeInsets.zero,
                onChanged: widget.enabled
                    ? (value) => setState(() {
                          final repeatValue = value ? _repeatValue : null;
                          state.didChange(RepeatData(repeatValue, repeatValue == RepeatOptions.custom ? _intervalValue : null));
                        })
                    : null,
              ),
              CollapsibleContainer(
                collapsed: !isRepeat,
                child: Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<RepeatOptions>(
                      value: stateValue.repeat,
                      isExpanded: true,
                      style: Theme.of(context).textTheme.bodyMedium,
                      onChanged: widget.enabled
                          ? (value) => setState(() {
                                final repeatValue = value ?? RepeatOptions.daily;
                                state.didChange(RepeatData(repeatValue, repeatValue == RepeatOptions.custom ? _intervalValue : null));
                                _repeatValue = repeatValue;
                              })
                          : null,
                      items: RepeatOptions.values.map((option) {
                        return DropdownMenuItem<RepeatOptions>(
                          value: option,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(option.label(context)),
                              Icon(option.icon, color: widget.enabled ? null : Theme.of(context).disabledColor),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
              CollapsibleContainer(
                collapsed: !(isRepeat && _repeatValue == RepeatOptions.custom),
                child: Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: NumberFormField<int>(
                    enabled: widget.enabled,
                    initialValue: _intervalValue,
                    decoration: (widget.intervalInputDecoration ?? const InputDecoration()).copyWith(
                      errorText: state.errorText,
                      errorStyle: const TextStyle(fontSize: 0),
                    ),
                    onChanged: (value) => setState(() {
                      state.didChange(RepeatData(stateValue.repeat, value));
                      _intervalValue = value;
                    }),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
