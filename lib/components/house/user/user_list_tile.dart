import 'package:flutter/material.dart';
import 'package:house_wallet/data/logged_user.dart';
import 'package:house_wallet/data/user.dart';
import 'package:house_wallet/main.dart';
import 'package:house_wallet/pages/house/user_details_bottom_sheet.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

class UserListTile extends StatelessWidget {
  final User? user;

  UserListTile(User this.user) : super(key: Key(user.uid));

  const UserListTile.invite({super.key}) : user = null;

  void _openUserDetails(BuildContext context) {
    if (user == null) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => UserDetailsBottomSheet(user!, loggedUser: Provider.of<LoggedUser>(context)),
    );
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
      title: Text(user!.uid == Provider.of<LoggedUser>(context).uid ? localizations(context).userYou(user!.username) : user!.username),
      onTap: () => _openUserDetails(context),
    );
  }
}
