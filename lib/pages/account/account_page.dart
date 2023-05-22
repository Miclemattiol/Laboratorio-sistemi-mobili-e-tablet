import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_series/flutter_series.dart';
import 'package:house_wallet/components/sliding_page_route.dart';
import 'package:house_wallet/components/ui/app_bar_fix.dart';
import 'package:house_wallet/components/ui/custom_dialog.dart';
import 'package:house_wallet/components/ui/link_list_tile.dart';
import 'package:house_wallet/components/user_avatar.dart';
import 'package:house_wallet/data/firestore.dart';
import 'package:house_wallet/data/logged_user.dart';
import 'package:house_wallet/main.dart';
import 'package:house_wallet/pages/account/notifications_page.dart';

class AccountPage extends StatelessWidget {
  const AccountPage({super.key});

  void _logout(BuildContext context) async {
    if (!await CustomDialog.confirm(
      context: context,
      title: localizations(context).logoutDialogTitle,
      content: localizations(context).logoutDialogContent,
    )) return;

    FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarFix(title: Text(localizations(context).accountPage)),
      body: FutureBuilder(
          future: FirestoreData.getUser(LoggedUser.uid!),
          builder: (context, snapshot) {
            final user = snapshot.data;

            if (user == null) {
              //TODO loader, error message
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: Text("Loading..."));
              } else {
                return Center(child: Text("Error (${snapshot.error})"));
              }
            }

            return ListView(
              children: [
                PadColumn(
                  spacing: 16,
                  padding: const EdgeInsets.all(16),
                  children: [
                    Row(
                      children: [
                        UserAvatar(user.imageUrl, size: 128),
                        Expanded(child: Center(child: Text(user.username)))
                      ],
                    ),
                    TextFormField(
                      initialValue: user.iban,
                      decoration: InputDecoration(border: const OutlineInputBorder(), labelText: localizations(context).ibanInput),
                    ),
                    TextFormField(
                      initialValue: user.payPal,
                      decoration: InputDecoration(border: const OutlineInputBorder(), labelText: localizations(context).paypalInput),
                    ),
                  ],
                ),
                LinkListTile(
                  title: localizations(context).notificationsPage,
                  onTap: () => Navigator.of(context).push(SlidingPageRoute(const NotificationsPage())),
                ),
                LinkListTile(
                  title: localizations(context).changePasswordPage,
                  onTap: () => Navigator.of(context).push(SlidingPageRoute(const NotificationsPage())),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: ElevatedButton(
                    onPressed: () => _logout(context),
                    child: Text(localizations(context).logoutButton),
                  ),
                ),
              ],
            );
          }),
    );
  }
}
