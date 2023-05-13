import 'package:flutter/material.dart';

class Transazioni extends StatelessWidget {
  const Transazioni({super.key});

  static const label = "Transazioni";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(label)),
      body: const Center(child: Text(label)),
    );
  }
}
