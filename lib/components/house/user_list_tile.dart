import 'package:flutter/material.dart';
import 'package:house_wallet/main.dart';

class UserListTile extends StatelessWidget {
  final String? user;

  const UserListTile(
    String this.user, {
    super.key,
  });

  const UserListTile.invite({super.key}) : user = null;

  @override
  Widget build(BuildContext context) {
    final user = this.user;

    if (user == null) {
      return ListTile(
        leading: const CircleAvatar(child: Icon(Icons.ios_share)),
        title: Text(localizations(context).userInvite),
      );
    }

    return ListTile(
      leading: const CircleAvatar(child: Icon(Icons.person)),
      title: Text(user),
    );
  }
}
