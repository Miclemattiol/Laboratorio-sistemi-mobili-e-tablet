import 'package:flutter/material.dart';

class LinkListTile extends StatelessWidget {
  final String title;
  final void Function()? onTap;

  const LinkListTile({
    required this.title,
    this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      onTap: onTap,
      trailing: const Icon(Icons.keyboard_arrow_right, color: Colors.black),
    );
  }
}
