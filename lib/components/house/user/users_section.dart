import 'package:flutter/material.dart';
import 'package:house_wallet/components/house/section.dart';
import 'package:house_wallet/components/house/user/user_list_tile.dart';
import 'package:house_wallet/data/house_data.dart';
import 'package:house_wallet/main.dart';

class UsersSection extends StatelessWidget {
  const UsersSection({super.key});

  @override
  Widget build(BuildContext context) {
    final users = HouseDataRef.of(context).users.values.toList()..sort((a, b) => a.username.compareTo(b.username));
    return Section(
      title: localizations(context).usersSection,
      children: [
        ...users.map(UserListTile.new),
        const UserListTile.invite(),
      ],
    );
  }
}
