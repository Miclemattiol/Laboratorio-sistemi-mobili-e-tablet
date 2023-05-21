import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:house_wallet/components/house/section.dart';
import 'package:house_wallet/components/house/user/user_list_tile.dart';
import 'package:house_wallet/data/logged_user.dart';
import 'package:house_wallet/data/user.dart';
import 'package:house_wallet/main.dart';

class UsersSection extends StatelessWidget {
  final AsyncSnapshot<Iterable<User>> snapshot;

  const UsersSection(this.snapshot, {super.key});

  static DocumentReference<Map<String, dynamic>> get firestoreRef => FirebaseFirestore.instance.doc("/groups/${LoggedUser.houseId}/");

  @override
  Widget build(BuildContext context) {
    return Section(
      title: localizations(context).usersSection,
      children: () {
        final users = snapshot.data;

        if (users == null) {
          //TODO loader, error message
          if (snapshot.connectionState == ConnectionState.waiting) {
            return [
              const Center(child: Text("Loading..."))
            ];
          } else {
            return [
              Center(child: Text("Error (${snapshot.error})"))
            ];
          }
        }

        return [
          ...users.map(UserListTile.new),
          const UserListTile.invite(),
        ];
      }(),
    );
  }
}
