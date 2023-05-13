import 'package:flutter/material.dart';

class Casa extends StatelessWidget {
  const Casa({super.key});

  static const label = "Casa";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(label)),
      body: const Center(child: Text(label)),
    );
  }
}
