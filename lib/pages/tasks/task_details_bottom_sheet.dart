import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:house_wallet/components/form/date_picker_form_field.dart';
import 'package:house_wallet/components/form/number_form_field.dart';
import 'package:house_wallet/components/ui/collapsible_container.dart';
import 'package:house_wallet/components/ui/custom_bottom_sheet.dart';
import 'package:house_wallet/components/ui/modal_button.dart';
import 'package:house_wallet/data/firestore.dart';
import 'package:house_wallet/data/house_data.dart';
import 'package:house_wallet/data/logged_user.dart';
import 'package:house_wallet/data/tasks/task.dart';
import 'package:house_wallet/main.dart';
import 'package:house_wallet/pages/tasks/tasks_page.dart';
import 'package:house_wallet/themes.dart';

enum RepeatOptions {
  //Never, // -1
  Daily, // 0
  Weekly, // 1
  Monthly, // 2
  Yearly, // 3
  Custom, // 4
}

extension RepeatOptionsValues on RepeatOptions {
  IconData get icon {
    switch (this) {
      case RepeatOptions.Daily:
        return Icons.repeat_one;
      case RepeatOptions.Weekly:
        return Icons.repeat;
      case RepeatOptions.Monthly:
        return Icons.calendar_month_outlined;
      case RepeatOptions.Yearly:
        return Icons.calendar_today_outlined;
      case RepeatOptions.Custom:
        return Icons.edit_calendar_outlined;
    }
  }

  String getName(BuildContext context) {
    switch (this) {
      case RepeatOptions.Daily:
        return localizations(context).taskRepeatDaily;
      case RepeatOptions.Weekly:
        return localizations(context).taskRepeatWeekly;
      case RepeatOptions.Monthly:
        return localizations(context).taskRepeatMonthly;
      case RepeatOptions.Yearly:
        return localizations(context).taskRepeatYearly;
      case RepeatOptions.Custom:
        return localizations(context).taskRepeatCustom;
    }
  }
}

class TaskDetailsBottomSheet extends StatefulWidget {
  final LoggedUser loggedUser;
  final HouseDataRef house;
  final FirestoreDocument<TaskRef>? task;

  const TaskDetailsBottomSheet({
    required this.loggedUser,
    required this.house,
    super.key,
  }) : task = null;

  const TaskDetailsBottomSheet.edit(this.task, {required this.loggedUser, required this.house, super.key});

  @override
  State<TaskDetailsBottomSheet> createState() => _TaskDetailsBottomSheetState();
}

class _TaskDetailsBottomSheetState extends State<TaskDetailsBottomSheet> {
  @override
  void initState() {
    super.initState();
    if (widget.task != null) {
      _repeat = widget.task?.data.repeating != null && widget.task!.data.repeating != -1;
      if (_repeat) {
        repeatValue = RepeatOptions.values[widget.task!.data.repeating];
      }
    }
  }

  final _formKey = GlobalKey<FormState>();

  bool _edited = false;
  String? _titleValue;
  String? _descriptionValue;
  DateTime? _startDate;
  DateTime? _endDate;
  bool _repeat = false;
  RepeatOptions repeatValue = RepeatOptions.values.first;
  DateTime? _startDateChangedValue;
  int? _intervalValue;

  _saveTask() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();
    try {
      Task task = Task(
        title: _titleValue!,
        description: _descriptionValue,
        from: _startDate!,
        to: _endDate!,
        repeating: _repeat ? repeatValue.index : -1,
        interval: repeatValue.index == RepeatOptions.values.length - 1 ? _intervalValue : null,
        assignedTo: [],
      );

      task; //TODO: save task

      if (widget.task == null) {
        await TasksPage.tasksFirestoreRef(widget.house.id).add(task);
      } else {
        await widget.task!.reference.update(Task.toFirestore(task));
      }

      navigator.pop();
    } on FirebaseException catch (e) {
      scaffoldMessenger.showSnackBar(SnackBar(content: Text("${localizations(context).saveChangesDialogContentError}\n(${e.message})")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: CustomBottomSheet(
        spacing: 16,
        body: [
          TextFormField(
            initialValue: widget.task?.data.title,
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
            initialValue: widget.task?.data.from,
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
            initialValue: widget.task?.data.to,
            decoration: inputDecoration("Data fine"),
            onSaved: (newValue) {
              _endDate = newValue;
            },
            onChanged: (newValue) {
              if (!_edited) {
                _edited = true;
              }
            },
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
                title: const Text("Ripeti"), //todo translate
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
                    child: DropdownButton<RepeatOptions>(
                      value: repeatValue,
                      isExpanded: true,
                      style: const TextStyle(fontWeight: FontWeight.normal, color: Colors.black), //TODO set color to theme
                      items: RepeatOptions.values
                          .map(
                            (option) => DropdownMenuItem<RepeatOptions>(
                              value: option,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(option.getName(context)),
                                  Icon(option.icon),
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
                collapsed: !_repeat || repeatValue != RepeatOptions.Custom,
                child: Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: NumberFormField<int>(
                    initialValue: widget.task?.data.interval,
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
            initialValue: widget.task?.data.description,
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
