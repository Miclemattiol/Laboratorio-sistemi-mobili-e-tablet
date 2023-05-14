import 'package:flutter/material.dart';
import 'package:house_wallet/components/ui/app_bar_fix.dart';

class Profilo extends StatelessWidget {
  const Profilo({super.key});

  static const label = "Profilo";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarFix(title: const Text(label)),
      body: const Center(child: Text(label)),
    );
  }
}
