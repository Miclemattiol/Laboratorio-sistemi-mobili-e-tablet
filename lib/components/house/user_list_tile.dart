import 'package:flutter/material.dart';
import 'package:house_wallet/components/ui/bottom_sheet_container.dart';
import 'package:house_wallet/data/firestore.dart';
import 'package:house_wallet/data/logged_user.dart';
import 'package:house_wallet/data/user.dart';
import 'package:house_wallet/main.dart';
import 'package:house_wallet/pages/house/user_details_bottom_sheet.dart';
import 'package:share_plus/share_plus.dart';

class UserListTile extends StatelessWidget {
  final FirestoreDocument<User>? user;

  const UserListTile(
    FirestoreDocument<User> this.user, {
    super.key,
  });

  const UserListTile.invite({super.key}) : user = null;

  void _openUserDetails(BuildContext context) {
    if (user == null) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: BottomSheetContainer.borderRadius,
      builder: (context) => UserDetailsBottomSheet(user!),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return ListTile(
        leading: const CircleAvatar(child: Icon(Icons.ios_share, size: 20)),
        title: Text(localizations(context).userInvite),
        onTap: () => Share.share("https://it.wikipedia.org/wiki/Moai"), //TODO group code
      );
    }

    return ListTile(
      leading: CircleAvatar(
        foregroundImage: NetworkImage(user!.data.imageUrl ?? ""),
        onForegroundImageError: (exception, stackTrace) {},
        child: const Icon(Icons.person, size: 20),
      ),
      title: Text(user!.id == LoggedUser.uid ? localizations(context).userYou(user!.data.username) : user!.data.username),
      onTap: () => _openUserDetails(context),
    );
  }
}
