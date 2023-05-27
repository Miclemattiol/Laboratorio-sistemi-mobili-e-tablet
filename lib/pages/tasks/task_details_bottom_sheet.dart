import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:house_wallet/components/form/date_picker_form_field.dart';
import 'package:house_wallet/components/form/number_form_field.dart';
import 'package:house_wallet/components/ui/collapsible_container.dart';
import 'package:house_wallet/components/ui/custom_bottom_sheet.dart';
import 'package:house_wallet/components/ui/modal_button.dart';
import 'package:house_wallet/data/tasks/task.dart';
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
  late String repeatValue = repeatOptions.keys.first;
  DateTime? _startDateChangedValue;
  int? _intervalValue;

  late Map<String, IconData> repeatOptions = {
    //Never                                       //-1
    localizations(context).taskRepeatDaily: Icons.repeat_one, //0
    localizations(context).taskRepeatWeekly: Icons.repeat, //1
    localizations(context).taskRepeatMonthly: Icons.calendar_month_outlined, //2
    localizations(context).taskRepeatYearly: Icons.calendar_today_outlined, //3
    localizations(context).taskRepeatCustom: Icons.edit_calendar_outlined, //4
  };

  _saveTask() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    int repeating = repeatOptions.keys.toList().indexOf(repeatValue);

    Task task = Task(
      title: _titleValue!,
      description: _descriptionValue,
      from: _startDate!,
      to: _endDate!,
      repeating: _repeat ? repeating : -1,
      interval: repeating == repeatOptions.keys.length - 1 ? _intervalValue : null,
      assignedTo: [],
    );

    print("Task: ${task.title} - ${task.description} - ${task.from} - ${task.to} - ${task.repeating} - ${task.interval} - ${task.assignedTo}");

    task; //TODO: save task

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
              _startDateChangedValue = newValue;
              if (!_edited) {
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
              if (!_edited) {
                _edited = true;
              }
            },
            initialValue: _startDate,
            validator: (value) {
              if (value == null) {
                return localizations(context).taskDateInvalid;
              } else if (_startDateChangedValue?.isAfter(value) ?? false) {
                return localizations(context).taskEndDateBeforeStartDate;
              }
              return null;
            },
          ),
          Column(
            children: [
              SwitchListTile(
                title: const Text("Ripeti"),
                contentPadding: EdgeInsets.zero,
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
              CollapsibleContainer(
                collapsed: !_repeat,
                child: Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: DropdownButtonHideUnderline(
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
                ),
              ),
              CollapsibleContainer(
                collapsed: !_repeat || repeatValue != localizations(context).taskRepeatCustom,
                child: Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: NumberFormField<int>(
                    decoration: inputDecoration(localizations(context).taskRepeatCustomPrompt),
                    validator: (value) {
                      if (value == null || value < 1) return localizations(context).taskRepeatCustomInvalid;
                      return null;
                    },
                    onChanged: (value) {
                      setState(() {
                        if (!_edited) {
                          setState(() {
                            _edited = true;
                          });
                        }
                      });
                    },
                    onSaved: (value) => _intervalValue = value,
                  ),
                ),
              ),
            ],
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
