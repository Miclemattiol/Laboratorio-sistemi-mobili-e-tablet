import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:house_wallet/components/house/section.dart';
import 'package:house_wallet/components/house/user/user_list_tile.dart';
import 'package:house_wallet/data/house_data.dart';
import 'package:house_wallet/data/logged_user.dart';
import 'package:house_wallet/main.dart';
import 'package:provider/provider.dart';

class UsersSection extends StatelessWidget {
  const UsersSection({super.key});

  static DocumentReference<Map<String, dynamic>> firestoreRef(BuildContext context) => FirebaseFirestore.instance.doc("/groups/${Provider.of<LoggedUser>(context).houseId}/");

  @override
  Widget build(BuildContext context) {
    final users = Provider.of<HouseDataRef>(context).users.values.toList()..sort((a, b) => a.username.compareTo(b.username));
    return Section(
      title: localizations(context).usersSection,
      children: [
        ...users.map(UserListTile.new),
        const UserListTile.invite(),
      ],
    );
  }
}
