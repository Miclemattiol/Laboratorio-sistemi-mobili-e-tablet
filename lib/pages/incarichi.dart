import 'package:flutter/material.dart';

class Incarichi extends StatelessWidget {
  const Incarichi({super.key});

  static const label = "Incarichi";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(label)),
      body: const Center(child: Text(label)),
    );
  }
}
