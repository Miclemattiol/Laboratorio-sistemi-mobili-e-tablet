import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:house_wallet/components/ui/app_bar_fix.dart';
import 'package:house_wallet/data/firestore.dart';
import 'package:house_wallet/data/house_data.dart';
import 'package:house_wallet/data/logged_user.dart';
import 'package:house_wallet/data/tasks/task.dart';
import 'package:house_wallet/main.dart';
import 'package:house_wallet/pages/tasks/task_details_bottom_sheet.dart';
import 'package:house_wallet/pages/tasks/tasks_tab.dart';
import 'package:intl/intl.dart';

DateFormat taskDateFormat(BuildContext context) => DateFormat("dd/MM", Localizations.localeOf(context).languageCode);

class TabData {
  final String label;
  final Widget widget;

  const TabData({required this.label, required this.widget});
}

class TasksPage extends StatelessWidget {
  const TasksPage({super.key});

  static CollectionReference<Task> tasksFirestoreRef(String houseId) => FirebaseFirestore.instance.collection("/groups/$houseId/tasks").withConverter(fromFirestore: Task.fromFirestore, toFirestore: Task.toFirestore);

  List<TabData> _tabs(BuildContext context, Iterable<FirestoreDocument<TaskRef>> tasks) {
    return [
      TabData(
        label: localizations(context).myTasksTab,
        widget: TasksTab.myTasks(tasks.where((task) => task.data.assignedTo.contains(LoggedUser.of(context).getUserData(context))).toList()),
      ),
      TabData(
        label: localizations(context).allTasksTab,
        widget: TasksTab.allTasks(tasks.toList()),
      ),
    ];
  }

  void _addTask(BuildContext context) {
    final loggedUser = LoggedUser.of(context, listen: false);
    final house = HouseDataRef.of(context, listen: false);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => TaskDetailsBottomSheet(loggedUser: loggedUser, house: house),
    );
  }

  @override
  Widget build(BuildContext context) {
    final houseId = HouseDataRef.of(context).id;
    return StreamBuilder(
      stream: tasksFirestoreRef(houseId).snapshots().map(TaskRef.converter(context)),
      builder: (context, snapshot) {
        final tasks = snapshot.data;

        if (tasks == null) {
          //TODO loading and error messages
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: Text("Loading"));
          } else {
            return Center(child: Text("Error (${snapshot.error})"));
          }
        }

        final tabs = _tabs(context, tasks);
        return DefaultTabController(
          length: tabs.length,
          child: Scaffold(
            appBar: AppBarFix(
              title: Text(localizations(context).tasksPage),
              bottom: TabBar(tabs: tabs.map((tab) => Tab(text: tab.label)).toList()),
            ),
            body: TabBarView(children: tabs.map((tab) => tab.widget).toList()),
            floatingActionButton: FloatingActionButton(
              heroTag: null,
              onPressed: () => _addTask(context),
              child: const Icon(Icons.add),
            ),
          ),
        );
      },
    );
  }
}
