import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
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

class TasksPage extends StatefulWidget {
  const TasksPage({super.key});

  static CollectionReference<Task> tasksFirestoreRef(String houseId) => FirebaseFirestore.instance.collection("/groups/$houseId/tasks").withConverter(fromFirestore: Task.fromFirestore, toFirestore: Task.toFirestore);

  @override
  State<TasksPage> createState() => _TasksPageState();
}

class _TasksPageState extends State<TasksPage> {
  bool _showFab = true;

  bool onNotification(UserScrollNotification notification) {
    setState(() => _showFab = notification.direction == ScrollDirection.idle);
    return true;
  }

  List<TabData> _tabs(BuildContext context, AsyncSnapshot<Iterable<FirestoreDocument<TaskRef>>> snapshot) {
    return [
      TabData(
        label: localizations(context).myTasksTab,
        widget: TasksTab(snapshot: snapshot, myTasks: true, onNotification: onNotification),
      ),
      TabData(
        label: localizations(context).allTasksTab,
        widget: TasksTab(snapshot: snapshot, myTasks: false, onNotification: onNotification),
      ),
    ];
  }

  void _addTask(BuildContext context) {
    final loggedUser = LoggedUser.of(context, listen: false);
    final house = HouseDataRef.of(context, listen: false);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      enableDrag: false,
      builder: (context) => TaskDetailsBottomSheet(loggedUser: loggedUser, house: house),
    );
  }

  @override
  Widget build(BuildContext context) {
    final houseId = HouseDataRef.of(context).id;
    return StreamBuilder(
      stream: TasksPage.tasksFirestoreRef(houseId).snapshots().map(TaskRef.converter(context)),
      builder: (context, snapshot) {
        final tabs = _tabs(context, snapshot);
        return DefaultTabController(
          length: tabs.length,
          child: Scaffold(
            appBar: AppBarFix(
              title: Text(localizations(context).tasksPage),
              bottom: TabBar(tabs: tabs.map((tab) => Tab(text: tab.label)).toList()),
            ),
            body: TabBarView(children: tabs.map((tab) => tab.widget).toList()),
            floatingActionButton: _showFab
                ? FloatingActionButton(
                    heroTag: null,
                    onPressed: () => _addTask(context),
                    child: const Icon(Icons.add),
                  )
                : null,
          ),
        );
      },
    );
  }
}
