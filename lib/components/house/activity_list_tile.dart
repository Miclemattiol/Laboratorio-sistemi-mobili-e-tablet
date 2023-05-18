import 'package:flutter/material.dart';
import 'package:house_wallet/data/house/activity.dart';
import 'package:house_wallet/main.dart';

class ActivityListTile extends StatelessWidget {
  final Activity activity;

  const ActivityListTile(
    this.activity, {
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: SizedBox(height: double.infinity, child: Icon(activity.type.icon)),
      title: const Text("Hai eliminato \"Pane\" dalla lista della spesa"),
      subtitle: Text(dateFormat(context).format(activity.date)),
    );
  }
}
