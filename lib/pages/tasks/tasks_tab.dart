import 'package:flutter/material.dart';
import 'package:house_wallet/data/tasks/calendar.dart';
import 'package:house_wallet/data/tasks/task.dart';
import 'package:house_wallet/components/tasks/task_list_tile.dart';

class TasksTab extends StatelessWidget {
  final List<Task> tasks;
  final bool showCalendar;

  const TasksTab.myTasks(this.tasks, {super.key}) : showCalendar = true;
  const TasksTab.allTasks(this.tasks, {super.key}) : showCalendar = false;

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        if (showCalendar) const Calendar(),
        ...tasks.map(TaskListTile.new)
      ],
    );
  }
}
