import 'package:flutter/material.dart';
import 'package:house_wallet/components/ui/app_bar_fix.dart';
import 'package:house_wallet/data/tasks/calendar.dart';
import 'package:house_wallet/data/tasks/task.dart';
import 'package:house_wallet/main.dart';
import 'package:house_wallet/pages/tasks/task_details_bottom_sheet.dart';

class TaskDetailsPage extends StatelessWidget {
  final Task task;

  const TaskDetailsPage(this.task, {super.key});

  void _editTask(BuildContext context) {
    // showModalBottomSheet(
    //   context: context,
    //   isScrollControlled: true,
    //   builder: (context) => TaskDetailsBottomSheet.edit(task),
    // );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarFix(
        title: Text(task.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            splashRadius: 24,
            tooltip: localizations(context).taskDelete,
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.edit),
            splashRadius: 24,
            tooltip: localizations(context).taskEdit,
            onPressed: () {
              //show modal bottom sheet
              _editTask(context);
            },
          )
        ],
      ),
      body: ListView(children: [
        const Calendar(),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(task.description ?? ""),
        )
      ]),
    );
  }
}
