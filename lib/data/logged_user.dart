import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/material.dart';
import 'package:house_wallet/data/house_data.dart';
import 'package:house_wallet/data/user.dart';
import 'package:house_wallet/main.dart';
import 'package:provider/provider.dart';

class LoggedUser {
  static LoggedUser of(BuildContext context, {bool listen = true}) => Provider.of<LoggedUser>(context, listen: listen);

  final auth.User authUser;
  final List<String> houses;

  const LoggedUser._(this.authUser, this.houses);

  String get uid => authUser.uid;

  User getUserData(BuildContext context, {bool listen = true}) => HouseDataRef.of(context, listen: listen).getUser(uid);

  static Query<HouseData> _groupsFirestoreRef(String uid) => App.groupsFirestoreReference.where(HouseData.usersKey, arrayContains: uid);

  static Widget stream({required Widget Function(BuildContext context, AsyncSnapshot<LoggedUser?> snapshot) builder}) {
    return StreamBuilder(
      stream: auth.FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        final user = snapshot.data;
        return StreamBuilder<LoggedUser?>(
          stream: user == null ? Stream.value(null) : _groupsFirestoreRef(user.uid).snapshots().map((groups) => LoggedUser._(user, groups.docs.map((doc) => doc.id).toList())),
          builder: builder,
        );
      },
    );
  }
}
