import 'package:flutter/material.dart';
import 'package:house_wallet/components/ui/app_bar_fix.dart';
import 'package:house_wallet/pages/incarichi/incarichi_tab.dart';

class TabData {
  final String label;
  final Widget widget;

  const TabData({required this.label, required this.widget});
}

const _tabs = <TabData>[
  TabData(
    label: "Le mie attività",
    widget: IncarichiTab(text: "Le mie attività"),
  ),
  TabData(
    label: "Tutte le attività",
    widget: IncarichiTab(text: "Tutte le attività"),
  ),
];

class Incarichi extends StatelessWidget {
  const Incarichi({super.key});

  static const label = "Incarichi";

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: _tabs.length,
      child: Scaffold(
        appBar: AppBarFix(
          title: const Text(label),
          bottom: TabBar(
            tabs: _tabs.map((tab) => Tab(text: tab.label)).toList(),
          ),
        ),
        body: TabBarView(
          children: _tabs.map((tab) => tab.widget).toList(),
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
