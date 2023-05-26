import 'package:flutter/material.dart';
import 'package:house_wallet/components/ui/app_bar_fix.dart';
import 'package:house_wallet/data/tasks/calendar.dart';
import 'package:house_wallet/data/tasks/task.dart';
import 'package:house_wallet/main.dart';

class TaskDetailsPage extends StatelessWidget {
  final Task task;

  const TaskDetailsPage(this.task, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarFix(
        title: Text(localizations(context).task),
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
            onPressed: () {},
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
