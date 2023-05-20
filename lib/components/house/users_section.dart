import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:house_wallet/components/house/section.dart';
import 'package:house_wallet/components/house/user_list_tile.dart';
import 'package:house_wallet/data/firestore.dart';
import 'package:house_wallet/data/logged_user.dart';
import 'package:house_wallet/data/user.dart';
import 'package:house_wallet/main.dart';

class UsersSection extends StatelessWidget {
  const UsersSection({super.key});

  static DocumentReference<Map<String, dynamic>> get firestoreRef => FirebaseFirestore.instance.doc("/groups/${LoggedUser.houseId}/");
  static DocumentReference<User> userFirestoreRef(String userId) => FirebaseFirestore.instance.doc("/users/$userId").withConverter(fromFirestore: User.fromFirestore, toFirestore: User.toFirestore);

  static final _userCache = <String, FirestoreDocument<User>>{};
  Future<Iterable<FirestoreDocument<User>>?> _parseUsersList(AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>> snapshot) async {
    try {
      final usersIds = List<String>.from(snapshot.data!.data()!["users"]);

      final users = await Future.wait<FirestoreDocument<User>?>(usersIds.map((id) async {
        if (!_userCache.containsKey(id)) {
          try {
            final doc = await userFirestoreRef(id).get();
            _userCache[id] = FirestoreDocument(doc, doc.data()!);
          } catch (_) {}
        }
        return _userCache[id];
      }));

      return users.whereType<FirestoreDocument<User>>();
    } catch (_) {}
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: firestoreRef.snapshots(),
      builder: (context, snapshot) => FutureBuilder(
        future: _parseUsersList(snapshot),
        builder: (context, snapshot) => Section(
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
        ),
      ),
    );
  }
}
