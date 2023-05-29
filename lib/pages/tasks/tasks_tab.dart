import 'package:flutter/material.dart';
import 'package:house_wallet/components/tasks/task_list_tile.dart';
import 'package:house_wallet/data/firestore.dart';
import 'package:house_wallet/data/logged_user.dart';
import 'package:house_wallet/data/tasks/calendar.dart';
import 'package:house_wallet/data/tasks/task.dart';
import 'package:house_wallet/main.dart';
import 'package:house_wallet/themes.dart';
import 'package:house_wallet/utils.dart';
import 'package:shimmer/shimmer.dart';

class TasksTab extends StatelessWidget {
  final AsyncSnapshot<Iterable<FirestoreDocument<TaskRef>>> snapshot;
  final bool myTasks;

  const TasksTab({
    required this.snapshot,
    required this.myTasks,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final tasks = snapshot.data?.where((task) => !myTasks || task.data.assignedTo.map((user) => user.uid).contains(LoggedUser.of(context).uid)).toList()?..sort((a, b) => (b.data.repeating != null).toInt() - (a.data.repeating != null).toInt());

    if (tasks == null) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return Shimmer.fromColors(
          baseColor: Theme.of(context).disabledColor,
          highlightColor: Theme.of(context).disabledColor.withOpacity(.1),
          child: Column(
            children: [
              TaskListTile.shimmer(titleWidth: 160, subtitleWidth: 96),
              TaskListTile.shimmer(titleWidth: 96, subtitleWidth: 80),
              TaskListTile.shimmer(titleWidth: 176, subtitleWidth: 96),
              TaskListTile.shimmer(titleWidth: 112, subtitleWidth: 40),
              TaskListTile.shimmer(titleWidth: 128, subtitleWidth: 96),
              TaskListTile.shimmer(titleWidth: 128, subtitleWidth: 96),
              TaskListTile.shimmer(titleWidth: 96, subtitleWidth: 32),
            ],
          ),
        );
      } else {
        return centerErrorText(context: context, message: localizations(context).tasksPageError, error: snapshot.error);
      }
    }

    //TODO empty list
    if (tasks.isEmpty) {
      return const Center(child: Text("🗿", style: TextStyle(fontSize: 64)));
    }

    return ListView(
      children: [
        if (myTasks) const Calendar(),
        ...tasks.map(TaskListTile.new)
      ],
    );
  }
}
