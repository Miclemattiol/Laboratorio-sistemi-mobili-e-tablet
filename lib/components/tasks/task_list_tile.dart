import 'package:flutter/material.dart';
import 'package:flutter_series/flutter_series.dart';
import 'package:house_wallet/components/ui/sliding_page_route.dart';
import 'package:house_wallet/data/tasks/task.dart';
import 'package:house_wallet/main.dart';
import 'package:house_wallet/pages/tasks/task_details_page.dart';
import 'package:house_wallet/pages/tasks/tasks_page.dart';

class TaskListTile extends StatelessWidget {
  final Task task;

  const TaskListTile(this.task, {super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: task.repeating ? const SizedBox(height: double.infinity, child: Icon(Icons.repeat)) : null,
      title: Text(task.title),
      subtitle: Text(localizations(context).taskAssignedTo(task.assignedTo.join(", "))),
      trailing: PadColumn(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        spacing: 2,
        children: [
          Text(localizations(context).taskFromDate(taskDateFormat(context).format(task.from))),
          Text(localizations(context).taskToDate(taskDateFormat(context).format(task.to)))
        ],
      ),
      onTap: () => Navigator.of(context).push(SlidingPageRoute(TaskDetailsPage(task), fullscreenDialog: true)),
    );
  }
}
