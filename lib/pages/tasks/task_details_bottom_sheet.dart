import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:house_wallet/components/form/date_picker_form_field.dart';
import 'package:house_wallet/components/form/repeat_interval_form_field.dart';
import 'package:house_wallet/components/ui/custom_bottom_sheet.dart';
import 'package:house_wallet/components/ui/modal_button.dart';
import 'package:house_wallet/data/firestore.dart';
import 'package:house_wallet/data/house_data.dart';
import 'package:house_wallet/data/logged_user.dart';
import 'package:house_wallet/data/tasks/task.dart';
import 'package:house_wallet/main.dart';
import 'package:house_wallet/pages/tasks/tasks_page.dart';
import 'package:house_wallet/themes.dart';

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
    this.task, {
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
  RepeatData? _repeatValue;

  _saveTask() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    _formKey.currentState!.save();
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    try {
      Task task = Task(
        title: _titleValue!,
        description: _descriptionValue,
        from: _fromValue!,
        to: _toValue!,
        repeating: _repeatValue!.repeat,
        interval: _repeatValue!.interval,
        assignedTo: [],
      );

      if (widget.task == null) {
        await TasksPage.tasksFirestoreRef(widget.house.id).add(task);
      } else {
        await widget.task!.reference.update(Task.toFirestore(task));
      }

      navigator.pop();
    } on FirebaseException catch (error) {
      scaffoldMessenger.showSnackBar(SnackBar(content: Text("${localizations(context).saveChangesDialogContentError}\n(${error.message})")));
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
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
            validator: (title) => (title == null || title.isEmpty) ? localizations(context).titleInputErrorMissing : null,
          ),
          DatePickerFormField.dateOnly(
            enabled: !_loading,
            initialValue: widget.task?.data.from,
            decoration: inputDecoration(localizations(context).taskStartDateInput),
            onSaved: (from) => _fromValue = from,
            validator: (from) {
              if (from == null) {
                return localizations(context).taskDateInputErrorMissing;
              } else if (_toValue?.isBefore(from) ?? false) {
                return localizations(context).taskStartDateInputErrorBeforeEndDate;
              }
              return null;
            },
          ),
          DatePickerFormField.dateOnly(
            enabled: !_loading,
            initialValue: widget.task?.data.to,
            decoration: inputDecoration(localizations(context).taskEndDateInput),
            onSaved: (to) => _toValue = to,
            validator: (to) {
              if (to == null) {
                return localizations(context).taskDateInputErrorMissing;
              } else if (_fromValue?.isAfter(to) ?? false) {
                return localizations(context).taskEndDateInputErrorBeforeStartDate;
              }
              return null;
            },
          ),
          RepeatIntervalFormField(
            enabled: !_loading,
            initialValues: RepeatData(widget.task?.data.repeating, widget.task?.data.interval),
            intervalInputDecoration: inputDecoration(localizations(context).taskRepeatCustomPrompt),
            onSaved: (repeat) => _repeatValue = repeat,
            validator: (value) {
              if (value?.repeat == RepeatOptions.custom) {
                if (value!.interval == null || value.interval! < 1) {
                  return localizations(context).taskIntervalErrorMissing;
                }
              }
              return null;
            },
          ),
          TextFormField(
            enabled: !_loading,
            minLines: 1,
            maxLines: 5,
            initialValue: widget.task?.data.description,
            decoration: inputDecoration(localizations(context).descriptionInput),
            keyboardType: TextInputType.multiline,
            onSaved: (description) => _descriptionValue = (description ?? "").trim().isEmpty ? null : description?.trim(),
          ),
        ],
        actions: [
          ModalButton(enabled: !_loading, onPressed: () => Navigator.of(context).pop(), child: Text(localizations(context).buttonCancel)),
          ModalButton(enabled: !_loading, onPressed: _saveTask, child: Text(localizations(context).buttonOk)),
        ],
      ),
    );
  }
}
