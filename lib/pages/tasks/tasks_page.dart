import 'package:flutter/material.dart';
import 'package:house_wallet/components/ui/app_bar_fix.dart';
import 'package:house_wallet/data/tasks/task.dart';
import 'package:house_wallet/main.dart';
import 'package:house_wallet/pages/tasks/tasks_tab.dart';
import 'package:intl/intl.dart';

DateFormat taskDateFormat(BuildContext context) => DateFormat("dd/MM", Localizations.localeOf(context).languageCode);

final tasks = <Task>[
  Task(
    title: "Task 1",
    from: DateTime(2023, 5, 18),
    to: DateTime(2023, 5, 20),
    repeating: true,
    description: "Descrizione 1",
    assignedTo: [
      "Mario Rossi"
    ],
  ),
  Task(
    title: "Task 2",
    from: DateTime(2023, 5, 20),
    to: DateTime(2023, 6, 2),
    repeating: false,
    description: "Descrizione 2",
    assignedTo: [
      "Mario Rossi",
      "Luigi Verdi",
      "Paolo Bianchi"
    ],
  ),
  Task(
    title: "Task 3",
    from: DateTime(2023, 5, 20),
    to: DateTime(2023, 5, 22),
    repeating: false,
    description: "Descrizione 3",
    assignedTo: [
      "Luigi Verdi"
    ],
  ),
];

class TabData {
  final String label;
  final Widget widget;

  const TabData({required this.label, required this.widget});
}

class TasksPage extends StatelessWidget {
  const TasksPage({super.key});

  List<TabData> _tabs(BuildContext context) {
    return [
      TabData(
        label: localizations(context).myTasksTab,
        widget: TasksTab.myTasks(tasks),
      ),
      TabData(
        label: localizations(context).allTasksTab,
        widget: TasksTab.allTasks(tasks),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final tabs = _tabs(context);
    return DefaultTabController(
      length: tabs.length,
      child: Scaffold(
        appBar: AppBarFix(
          title: Text(localizations(context).tasksPage),
          bottom: TabBar(
            tabs: tabs.map((tab) => Tab(text: tab.label)).toList(),
          ),
        ),
        body: TabBarView(
          children: tabs.map((tab) => tab.widget).toList(),
        ),
        floatingActionButton: FloatingActionButton(
          heroTag: null,
          onPressed: () {},
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
