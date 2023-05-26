import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/material.dart';
import 'package:house_wallet/data/house_data.dart';
import 'package:house_wallet/data/user.dart';
import 'package:provider/provider.dart';

class LoggedUser {
  final auth.User authUser;
  final List<String> houses;

  const LoggedUser(this.authUser, this.houses);

  String get uid => authUser.uid;
  String get houseId => houses.first;

  User getUserData(BuildContext context) => Provider.of<HouseDataRef>(context).getUser(uid);

  static Future<LoggedUser?> converter(auth.User? user) async {
    if (user == null) return null;

    final data = await FirebaseFirestore.instance.collection("/groups").where("users", arrayContains: user.uid).get();
    return LoggedUser(user, data.docs.map((doc) => doc.id).toList());
  }
}
