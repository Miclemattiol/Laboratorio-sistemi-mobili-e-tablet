import 'package:flutter/material.dart';
import 'package:house_wallet/components/ui/app_bar_fix.dart';
import 'package:house_wallet/main.dart';
import 'package:house_wallet/pages/tasks/tasks_tab.dart';

class TabData {
  final String label;
  final Widget widget;

  const TabData({required this.label, required this.widget});
}

List<TabData> _tabs(BuildContext context) {
  return [
    TabData(
      label: localizations(context).myTasksTab,
      widget: TasksTab(text: localizations(context).myTasksTab),
    ),
    TabData(
      label: localizations(context).allTasksTab,
      widget: TasksTab(text: localizations(context).allTasksTab),
    ),
  ];
}

class TasksPage extends StatelessWidget {
  const TasksPage({super.key});

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
