import 'package:flutter/material.dart';
import 'package:house_wallet/components/ui/app_bar_fix.dart';
import 'package:house_wallet/main.dart';

class RegistroAttivita extends StatelessWidget {
  const RegistroAttivita({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarFix(title: Text(localizations(context).activityLogPage)),
      body: ListView(
        children: const [
          ListTile(title: Text("Placeholder 1")),
          ListTile(title: Text("Placeholder 2")),
          ListTile(title: Text("Placeholder 3")),
        ],
      ),
    );
  }
}
