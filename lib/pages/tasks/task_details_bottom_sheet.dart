import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:house_wallet/components/form/date_picker_form_field.dart';
import 'package:house_wallet/components/form/people_form_field.dart';
import 'package:house_wallet/components/form/repeat_interval_form_field.dart';
import 'package:house_wallet/components/ui/custom_bottom_sheet.dart';
import 'package:house_wallet/components/ui/custom_dialog.dart';
import 'package:house_wallet/components/ui/modal_button.dart';
import 'package:house_wallet/data/firestore.dart';
import 'package:house_wallet/data/house_data.dart';
import 'package:house_wallet/data/logged_user.dart';
import 'package:house_wallet/data/tasks/task.dart';
import 'package:house_wallet/main.dart';
import 'package:house_wallet/pages/tasks/tasks_page.dart';
import 'package:house_wallet/themes.dart';
import 'package:house_wallet/utils.dart';

class TaskDetailsBottomSheet extends StatefulWidget {
  final LoggedUser loggedUser;
  final HouseDataRef house;
  final FirestoreDocument<TaskRef>? task;

  const TaskDetailsBottomSheet({
    required this.loggedUser,
    required this.house,
    super.key,
  }) : task = null;

  const TaskDetailsBottomSheet.edit(
    FirestoreDocument<TaskRef> this.task, {
    required this.loggedUser,
    required this.house,
    super.key,
  });

  @override
  State<TaskDetailsBottomSheet> createState() => _TaskDetailsBottomSheetState();
}

class _TaskDetailsBottomSheetState extends State<TaskDetailsBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  bool _loading = false;

  String? _titleValue;
  String? _descriptionValue;
  DateTime? _fromValue;
  DateTime? _toValue;
  late RepeatData? _repeatValue = widget.task?.data.repeatData;
  Set<String> _assignedToValue = {};

  _saveTask() async {
    final navigator = Navigator.of(context);

    _formKey.currentState!.save();
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    try {
      if (await isNotConnectedToInternet(context) || !mounted) return mounted ? setState(() => _loading = false) : null;

      final toValue = _repeatValue?.repeat == RepeatOptions.daily ? _fromValue! : _toValue!;
      if (widget.task == null) {
        await TasksPage.tasksFirestoreRef(widget.house.id).add(Task(
          title: _titleValue!,
          description: _descriptionValue,
          from: _fromValue!,
          to: toValue,
          repeating: _repeatValue!.repeat,
          interval: _repeatValue!.interval,
          assignedTo: _assignedToValue,
        ));
      } else {
        await widget.task!.reference.update({
          Task.titleKey: _titleValue!,
          Task.descriptionKey: _descriptionValue,
          Task.fromKey: _fromValue!,
          Task.toKey: toValue,
          Task.repeatingKey: _repeatValue!.repeat?.index,
          Task.intervalKey: _repeatValue!.interval,
          Task.assignedToKey: _assignedToValue,
        });
      }

      navigator.pop();
    } on FirebaseException catch (error) {
      if (!context.mounted) return;
      CustomDialog.alert(
        context: context,
        title: localizations(context).error,
        content: localizations(context).saveChangesError(error.message.toString()),
      );
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final todayDate = DateTime.now();
    final firstDate = DateTime(todayDate.year - 50, todayDate.month, todayDate.day);

    return Form(
      key: _formKey,
      child: CustomBottomSheet(
        dismissible: !_loading,
        spacing: 16,
        body: [
          TextFormField(
            enabled: !_loading,
            initialValue: widget.task?.data.title,
            decoration: inputDecoration(localizations(context).title),
            onSaved: (title) => _titleValue = title,
            validator: (title) => (title == null || title.isEmpty) ? localizations(context).titleMissing : null,
          ),
          DatePickerFormField.dateOnly(
            enabled: !_loading,
            initialValue: widget.task?.data.from,
            firstDate: firstDate,
            decoration: inputDecoration(_repeatValue?.repeat == RepeatOptions.daily ? localizations(context).date : localizations(context).startDate),
            onSaved: (from) => _fromValue = from,
            validator: (from) {
              if (from == null) {
                return localizations(context).dateMissing;
              } else if (_toValue?.isBefore(from) ?? false) {
                return localizations(context).startDateInvalid;
              } else if (_repeatValue?.repeat != null && _toValue != null) {
                final differenceInDays = DateTimeRange(start: from, end: _toValue!).duration.inDays;
                final repeat = _repeatValue!.repeat!;

                final errorRepeatWeekly = (repeat == RepeatOptions.weekly && differenceInDays >= DateTime.daysPerWeek);
                final errorRepeatMonthly = (repeat == RepeatOptions.monthly && differenceInDays >= 28);
                final errorRepeatYearly = (repeat == RepeatOptions.yearly && differenceInDays >= 365);
                final errorRepeatCustom = (repeat == RepeatOptions.custom && _repeatValue!.interval != null && differenceInDays >= _repeatValue!.interval!);
                if (errorRepeatWeekly || errorRepeatMonthly || errorRepeatYearly || errorRepeatCustom) {
                  return localizations(context).rangeDateInvalid;
                }
              }
              return null;
            },
          ),
          if (_repeatValue?.repeat != RepeatOptions.daily)
            DatePickerFormField.dateOnly(
              enabled: !_loading,
              initialValue: widget.task?.data.to,
              firstDate: firstDate,
              decoration: inputDecoration(localizations(context).endDate),
              onSaved: (to) => _toValue = to,
              validator: (to) {
                if (to == null) {
                  return localizations(context).dateMissing;
                } else if (_fromValue?.isAfter(to) ?? false) {
                  return localizations(context).endDateInvalid;
                } else if (_repeatValue?.repeat == null && !to.isAfter(DateTime.now())) {
                  return localizations(context).rangeEndDateInvalidPast;
                } else if (_repeatValue?.repeat != null && _fromValue != null) {
                  final differenceInDays = DateTimeRange(start: _fromValue!, end: to).duration.inDays;
                  final repeat = _repeatValue!.repeat!;

                  final errorRepeatWeekly = (repeat == RepeatOptions.weekly && differenceInDays >= DateTime.daysPerWeek);
                  final errorRepeatMonthly = (repeat == RepeatOptions.monthly && differenceInDays >= 28);
                  final errorRepeatYearly = (repeat == RepeatOptions.yearly && differenceInDays >= 365);
                  final errorRepeatCustom = (repeat == RepeatOptions.custom && _repeatValue!.interval != null && differenceInDays >= _repeatValue!.interval!);
                  if (errorRepeatWeekly || errorRepeatMonthly || errorRepeatYearly || errorRepeatCustom) {
                    return localizations(context).rangeDateInvalid;
                  }
                }
                return null;
              },
            ),
          RepeatIntervalFormField(
            enabled: !_loading,
            initialValues: _repeatValue,
            intervalInputDecoration: inputDecoration(localizations(context).interval),
            onSaved: (repeat) => _repeatValue = repeat,
            validator: (value) {
              if (value?.repeat == RepeatOptions.custom) {
                if (value!.interval == null || value.interval! < 1) {
                  return localizations(context).intervalMissing;
                }
              }
              return null;
            },
            onChanged: (repeat) => setState(() => _repeatValue = repeat),
          ),
          PeopleFormField(
            enabled: !_loading,
            house: widget.house,
            decoration: inputDecoration(localizations(context).assignedTo),
            initialValue: widget.task?.data.assignedTo.map((user) => user.uid).toSet() ?? widget.house.users.keys.toSet(),
            onSaved: (assignedTo) => _assignedToValue = assignedTo,
            validator: (assignedTo) => (assignedTo.isEmpty) ? localizations(context).assignedToMissing : null,
          ),
          TextFormField(
            enabled: !_loading,
            minLines: 1,
            maxLines: 5,
            initialValue: widget.task?.data.description,
            decoration: inputDecoration(localizations(context).description),
            keyboardType: TextInputType.multiline,
            onSaved: (description) => _descriptionValue = description.toNullable(),
          ),
        ],
        actions: [
          ModalButton(enabled: !_loading, onPressed: () => Navigator.of(context).pop(), child: Text(localizations(context).cancel)),
          ModalButton(enabled: !_loading, onPressed: _saveTask, child: Text(localizations(context).ok)),
        ],
      ),
    );
  }
}
