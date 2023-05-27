import 'package:flutter/material.dart';
import 'package:flutter_series/flutter_series.dart';
import 'package:house_wallet/components/ui/sliding_page_route.dart';
import 'package:house_wallet/data/firestore.dart';
import 'package:house_wallet/data/house_data.dart';
import 'package:house_wallet/data/logged_user.dart';
import 'package:house_wallet/data/tasks/task.dart';
import 'package:house_wallet/main.dart';
import 'package:house_wallet/pages/tasks/task_details_page.dart';
import 'package:house_wallet/pages/tasks/tasks_page.dart';

class TaskListTile extends StatelessWidget {
  final FirestoreDocument<TaskRef> task;

  const TaskListTile(this.task, {super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: task.data.repeating == null ? null : const SizedBox(height: double.infinity, child: Icon(Icons.repeat)),
      title: Text(task.data.title),
      subtitle: Text(task.data.assignedTo.isEmpty ? localizations(context).taskAssignedToNobody : localizations(context).taskAssignedTo(task.data.assignedTo.map((user) => user.username).join(", "))),
      trailing: PadColumn(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        spacing: 2,
        children: [
          Text(localizations(context).taskFromDate(taskDateFormat(context).format(task.data.from))),
          Text(localizations(context).taskToDate(taskDateFormat(context).format(task.data.to)))
        ],
      ),
      onTap: () => Navigator.of(context).push(SlidingPageRoute(TaskDetailsPage(task, house: HouseDataRef.of(context, listen: false), loggedUser: LoggedUser.of(context, listen: false)), fullscreenDialog: true)),
    );
  }
}
