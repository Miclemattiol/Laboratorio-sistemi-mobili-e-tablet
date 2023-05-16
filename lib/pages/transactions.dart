import 'package:flutter/material.dart';
import 'package:house_wallet/components/ui/app_bar_fix.dart';
import 'package:house_wallet/main.dart';

class Transactions extends StatelessWidget {
  const Transactions({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarFix(title: Text(localizations(context).transactionsPage)),
      body: Center(child: Text(localizations(context).transactionsPage)),
      floatingActionButton: FloatingActionButton(
        heroTag: null,
        onPressed: () {},
        child: const Icon(Icons.add),
      ),
    );
  }
}
