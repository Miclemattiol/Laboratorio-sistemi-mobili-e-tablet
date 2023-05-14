import 'package:flutter/material.dart';
import 'package:house_wallet/components/ui/app_bar_fix.dart';

class Transazioni extends StatelessWidget {
  const Transazioni({super.key});

  static const label = "Transazioni";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarFix(title: const Text(label)),
      body: const Center(child: Text(label)),
      floatingActionButton: FloatingActionButton(
        heroTag: null,
        onPressed: () {},
        child: const Icon(Icons.add),
      ),
    );
  }
}
