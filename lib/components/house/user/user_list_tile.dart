import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:house_wallet/data/house_data.dart';
import 'package:house_wallet/data/logged_user.dart';
import 'package:house_wallet/data/user.dart';
import 'package:house_wallet/main.dart';
import 'package:house_wallet/pages/house/user_details_bottom_sheet.dart';
import 'package:share_plus/share_plus.dart';

class UserListTile extends StatefulWidget {
  final User? user;

  UserListTile(User this.user) : super(key: Key(user.uid));

  const UserListTile.invite({super.key}) : user = null;

  @override
  State<UserListTile> createState() => _UserListTileState();
}

class _UserListTileState extends State<UserListTile> {
  bool _loading = false;

  void _openUserDetails(BuildContext context) {
    final loggedUser = LoggedUser.of(context, listen: false);
    final house = HouseDataRef.of(context, listen: false);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => UserDetailsBottomSheet(widget.user!, loggedUser: loggedUser, house: house),
    );
  }

  String _generateRandomCode(int length) {
    final random = Random();
    const chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890";
    return List.generate(length, (index) => chars[random.nextInt(chars.length)]).join();
  }

  void _createAndShareCode(BuildContext context) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final appLocalizations = localizations(context);

    setState(() => _loading = true);
    try {
      final code = _generateRandomCode(12);

      await HouseDataRef.of(context, listen: false).reference.update({
        HouseData.codesKey: FieldValue.arrayUnion([
          code
        ]),
      });

      Share.share(appLocalizations.shareContent(code));
    } on FirebaseException catch (error) {
      scaffoldMessenger.showSnackBar(SnackBar(content: Text("${appLocalizations.userDialogContentError}\n(${error.message})")));
    } finally {
      setState(() => _loading = false);
    }
  }

  String _username(context) {
    final myUid = LoggedUser.of(context).uid;

    String username = widget.user!.username;

    if (widget.user!.uid == myUid) {
      username += " ${localizations(context).userYou}";
    }
    if (widget.user!.uid == HouseDataRef.of(context).owner.uid) {
      username += " ${localizations(context).userOwner}";
    }

    return username;
  }

  BoxDecoration _balanceBackground(double value) {
    const opacity = .5;
    final redValue = value >= 0 ? 0 : -value;
    final greenValue = value <= 0 ? 0 : value;
    return BoxDecoration(
      gradient: LinearGradient(
        colors: [
          Colors.transparent,
          Colors.red.withOpacity(opacity),
          Colors.red.withOpacity(opacity),
          Colors.green.withOpacity(opacity),
          Colors.green.withOpacity(opacity),
          Colors.transparent,
        ],
        stops: [
          .5 - .5 * redValue,
          .5 - .5 * redValue,
          .5,
          .5,
          .5 + .5 * greenValue,
          .5 + .5 * greenValue
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.user == null) {
      return ListTile(
        leading: const CircleAvatar(child: Icon(Icons.ios_share, size: 20)),
        title: Text(localizations(context).userInvite),
        onTap: _loading ? null : () => _createAndShareCode(context),
      );
    }

    final house = HouseDataRef.of(context);
    final myBalance = house.getBalance(widget.user!.uid);
    final maxBalance = house.balances.values.reduce((prev, value) => prev > value.abs() ? prev : value.abs());

    return Container(
      decoration: _balanceBackground(myBalance / maxBalance),
      child: ListTile(
        tileColor: Colors.transparent,
        leading: CircleAvatar(
          foregroundImage: NetworkImage(widget.user!.imageUrl ?? ""),
          onForegroundImageError: (exception, stackTrace) {},
          child: const Icon(Icons.person, size: 20),
        ),
        trailing: Text("${myBalance > 0 ? "+" : ""}${currencyFormat(context).format(myBalance)}"),
        title: Text(_username(context)),
        onTap: () => _openUserDetails(context),
      ),
    );
  }
}
