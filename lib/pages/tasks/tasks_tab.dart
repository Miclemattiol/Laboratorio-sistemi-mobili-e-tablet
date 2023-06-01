import 'package:flutter/material.dart';
import 'package:house_wallet/components/tasks/calendar.dart';
import 'package:house_wallet/components/tasks/task_list_tile.dart';
import 'package:house_wallet/data/firestore.dart';
import 'package:house_wallet/data/logged_user.dart';
import 'package:house_wallet/data/tasks/task.dart';
import 'package:house_wallet/main.dart';
import 'package:house_wallet/themes.dart';
import 'package:house_wallet/utils.dart';
import 'package:shimmer/shimmer.dart';

class TasksTab extends StatelessWidget {
  final AsyncSnapshot<Iterable<FirestoreDocument<TaskRef>>> snapshot;
  final bool myTasks;
  final bool Function(UserScrollNotification notification)? onNotification;

  const TasksTab({
    required this.snapshot,
    required this.myTasks,
    required this.onNotification,
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

    if (tasks.isEmpty) {
      return centerSectionText(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(localizations(context).tasksPageEmpty, textAlign: TextAlign.center, style: Theme.of(context).textTheme.headlineMedium),
            Text(myTasks ? localizations(context).myTasksPageEmptyDescription : localizations(context).tasksPageEmptyDescription, textAlign: TextAlign.center, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.normal)),
          ],
        ),
      );
    }

    return NotificationListener<UserScrollNotification>(
      onNotification: onNotification,
      child: ListView(
        children: [
          if (myTasks) Calendar(tasks.map((task) => task.data.range).toList()),
          ...tasks.map(TaskListTile.new)
        ],
      ),
    );
  }
}
