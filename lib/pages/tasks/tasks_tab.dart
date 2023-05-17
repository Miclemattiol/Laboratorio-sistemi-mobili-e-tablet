import 'package:flutter/material.dart';

class TasksTab extends StatelessWidget {
  final String text;

  const TasksTab({
    required this.text,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Center(child: Text(text));
  }
}
