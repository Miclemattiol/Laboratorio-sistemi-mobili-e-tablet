import 'package:flutter/material.dart';
import 'package:house_wallet/components/form/date_picker_form_field.dart';
import 'package:house_wallet/components/ui/custom_bottom_sheet.dart';
import 'package:house_wallet/components/ui/modal_button.dart';
import 'package:house_wallet/main.dart';
import 'package:house_wallet/themes.dart';

class TaskDetailsBottomSheet extends StatefulWidget {
  const TaskDetailsBottomSheet({super.key});

  const TaskDetailsBottomSheet.edit({super.key});

  @override
  State<TaskDetailsBottomSheet> createState() => _TaskDetailsBottomSheetState();
}

class _TaskDetailsBottomSheetState extends State<TaskDetailsBottomSheet> {
  final _formKey = GlobalKey<FormState>();

  bool _edited = false;
  String? _titleValue;
  String? _descriptionValue;
  DateTime? _startDate;
  DateTime? _endDate;
  bool _repeat = false;
  String repeatValue = repeatOptions.keys.first;

  static Map<String, IconData> repeatOptions = {
    "Daily": Icons.repeat,
    "Weekly": Icons.repeat,
    "Monthly": Icons.repeat,
    "Yearly": Icons.repeat,
  };

  _saveTask() async {
    _formKey.currentState!.save();
    if (!_formKey.currentState!.validate()) return;

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: CustomBottomSheet(
        spacing: 16,
        body: [
          TextFormField(
            decoration: inputDecoration(localizations(context).title),
            onSaved: (newValue) {
              _titleValue = newValue;
            },
            validator: (value) {
              if (value == null || value.isEmpty) return localizations(context).paymentTitleInvalid;
              return null;
            },
          ),
          DatePickerFormField.dateOnly(
            decoration: inputDecoration("Data inizio"),
            onSaved: (newValue) {
              _startDate = newValue;
            },
            onChanged: (newValue) {
              if (!_edited && newValue != null) {
                _edited = true;
              }
            },
            validator: (value) {
              if (value == null) return localizations(context).taskDateInvalid;
              return null;
            },
          ),
          DatePickerFormField.dateOnly(
            decoration: inputDecoration("Data fine"),
            onSaved: (newValue) {
              _endDate = newValue;
            },
            onChanged: (newValue) {
              if (!_edited && newValue != null) {
                _edited = true;
              }
            },
            initialValue: _startDate,
            validator: (value) {
              if (value == null) {
                return localizations(context).taskDateInvalid;
              } else if (_startDate?.isAfter(value) ?? false) {
                return localizations(context).taskEndDateBeforeStartDate;
              }
              return null;
            },
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Ripeti"),
              Switch(
                value: _repeat,
                onChanged: (value) {
                  setState(() {
                    _repeat = value;
                    if (!_edited) {
                      _edited = true;
                    }
                  });
                },
              ),
            ],
          ),
          if (_repeat)
            DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: repeatValue,
                isExpanded: true,
                style: const TextStyle(fontWeight: FontWeight.normal, color: Colors.black), //TODO set color to theme
                items: repeatOptions.entries
                    .map(
                      (e) => DropdownMenuItem<String>(
                        value: e.key,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(e.key),
                            Icon(e.value),
                          ],
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    repeatValue = value!;
                    if (!_edited) {
                      _edited = true;
                    }
                  });
                },
              ),
            ),
          TextFormField(
            decoration: inputDecoration(localizations(context).descriptionInput),
            keyboardType: TextInputType.multiline,
            minLines: 1,
            maxLines: 5,
            onChanged: (description) {
              if (!_edited && description.trim().isNotEmpty) _edited = true;
            },
            onSaved: (description) => _descriptionValue = (description ?? "").trim().isEmpty ? null : description?.trim(),
          ),
        ],
        actions: [
          ModalButton(onPressed: () => Navigator.of(context).pop(), child: Text(localizations(context).buttonCancel)),
          ModalButton(onPressed: _saveTask, child: Text(localizations(context).buttonOk)),
        ],
      ),
    );
  }
}
