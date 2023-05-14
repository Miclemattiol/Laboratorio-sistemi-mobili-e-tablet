import 'package:flutter/material.dart';

class IncarichiTab extends StatelessWidget {
  final String text;

  const IncarichiTab({
    required this.text,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Center(child: Text(text));
  }
}
