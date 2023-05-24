import 'package:flutter/material.dart';
import 'package:house_wallet/components/ui/app_bar_fix.dart';
import 'package:house_wallet/main.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final Map<String, bool> _values = {
    "Placeholder 1": true,
    "Placeholder 2": true,
    "Placeholder 3": true,
    "Placeholder 4": true
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarFix(title: Text(localizations(context).notificationsPage)),
      body: ListView(
        children: _values.entries.map((e) {
          return SwitchListTile(
            title: Text(e.key),
            value: e.value,
            onChanged: (value) => setState(() => _values[e.key] = value),
          );
        }).toList(),
      ),
    );
  }
}
