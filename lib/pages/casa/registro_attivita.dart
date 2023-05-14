import 'package:flutter/material.dart';
import 'package:house_wallet/components/ui/app_bar_fix.dart';

class RegistroAttivita extends StatelessWidget {
  const RegistroAttivita({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarFix(title: const Text("Registro Attività")),
      body: ListView(
        children: const [
          ListTile(title: Text("Attività 1")),
          ListTile(title: Text("Attività 2")),
          ListTile(title: Text("Attività 3")),
        ],
      ),
    );
  }
}
