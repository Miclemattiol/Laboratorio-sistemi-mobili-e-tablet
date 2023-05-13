import 'package:flutter/material.dart';

class Profilo extends StatelessWidget {
  const Profilo({super.key});

  static const label = "Profilo";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(label)),
      body: const Center(child: Text(label)),
    );
  }
}
