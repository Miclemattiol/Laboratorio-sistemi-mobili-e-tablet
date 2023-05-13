import 'package:flutter/material.dart';

class Spesa extends StatelessWidget {
  const Spesa({super.key});

  static const label = "Spesa";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(label)),
      body: const Center(child: Text(label)),
    );
  }
}
