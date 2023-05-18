import 'package:flutter/material.dart';
import 'package:house_wallet/components/house/activity_list_tile.dart';
import 'package:house_wallet/components/ui/app_bar_fix.dart';
import 'package:house_wallet/data/house/activity.dart';
import 'package:house_wallet/main.dart';

final activities = <Activity>[
  Activity(type: ActivityType.shopping, date: DateTime(2023, 5, 18, 11, 11), details: []),
  Activity(type: ActivityType.shopping, date: DateTime(2020, 5, 17, 20, 12), details: []),
  Activity(type: ActivityType.trade, date: DateTime(2020, 5, 14, 11, 2), details: []),
  Activity(type: ActivityType.trade, date: DateTime(2020, 4, 1, 12, 30), details: []),
];

class ActivityLogPage extends StatelessWidget {
  const ActivityLogPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarFix(title: Text(localizations(context).activityLogPage)),
      body: ListView(children: activities.map(ActivityListTile.new).toList()),
    );
  }
}
