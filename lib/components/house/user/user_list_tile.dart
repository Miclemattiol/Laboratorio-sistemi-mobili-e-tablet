import 'package:flutter/material.dart';
import 'package:house_wallet/data/house_data.dart';
import 'package:house_wallet/data/logged_user.dart';
import 'package:house_wallet/data/user.dart';
import 'package:house_wallet/main.dart';
import 'package:house_wallet/pages/house/user_details_bottom_sheet.dart';
import 'package:share_plus/share_plus.dart';

class UserListTile extends StatelessWidget {
  final User? user;

  UserListTile(User this.user) : super(key: Key(user.uid));

  const UserListTile.invite({super.key}) : user = null;

  void _openUserDetails(BuildContext context) {
    final loggedUser = LoggedUser.of(context, listen: false);
    final house = HouseDataRef.of(context, listen: false);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => UserDetailsBottomSheet(user!, loggedUser: loggedUser, house: house),
    );
  }

  String _username(context) {
    final myUid = LoggedUser.of(context).uid;

    String username = user!.username;

    if (user!.uid == myUid) {
      username += " ${localizations(context).userYou}";
    }
    if (user!.uid == HouseDataRef.of(context).owner.uid) {
      username += " ${localizations(context).userOwner}";
    }

    return username;
  }

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return ListTile(
        leading: const CircleAvatar(child: Icon(Icons.ios_share, size: 20)),
        title: Text(localizations(context).userInvite),
        onTap: () => Share.share("https://it.wikipedia.org/wiki/Moai"), //TODO share group code
      );
    }

    return ListTile(
      leading: CircleAvatar(
        foregroundImage: NetworkImage(user!.imageUrl ?? ""),
        onForegroundImageError: (exception, stackTrace) {},
        child: const Icon(Icons.person, size: 20),
      ),
      title: Text(_username(context)),
      onTap: () => _openUserDetails(context),
    );
  }
}
