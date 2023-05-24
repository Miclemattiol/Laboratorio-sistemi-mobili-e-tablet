import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_series/flutter_series.dart';
import 'package:house_wallet/components/house/section.dart';
import 'package:house_wallet/components/house/user/user_list_tile.dart';
import 'package:house_wallet/data/logged_user.dart';
import 'package:house_wallet/data/user.dart';
import 'package:house_wallet/main.dart';
import 'package:shimmer/shimmer.dart';

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
          if (snapshot.connectionState == ConnectionState.waiting) {
            return [
              Shimmer.fromColors(
                baseColor: Theme.of(context).disabledColor,
                highlightColor: Theme.of(context).disabledColor.withOpacity(.1),
                child: Column(
                  children: [
                    PadRow(
                      padding: const EdgeInsets.all(16),
                      spacing: 16,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const CircleAvatar(),
                        Container(width: 160, height: 16, color: Colors.white),
                      ],
                    ),
                    PadRow(
                      padding: const EdgeInsets.all(16),
                      spacing: 16,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const CircleAvatar(),
                        Container(width: 96, height: 16, color: Colors.white),
                      ],
                    ),
                    PadRow(
                      padding: const EdgeInsets.all(16),
                      spacing: 16,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const CircleAvatar(),
                        Container(width: 128, height: 16, color: Colors.white),
                      ],
                    ),
                  ],
                ),
              )
            ];
          } else {
            return [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text("${localizations(context).usersSectionError} (${snapshot.error})"),
              )
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
