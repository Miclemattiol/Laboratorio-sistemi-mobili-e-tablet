import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_series/flutter_series.dart';
import 'package:house_wallet/components/sliding_page_route.dart';
import 'package:house_wallet/components/ui/app_bar_fix.dart';
import 'package:house_wallet/components/ui/link_list_tile.dart';
import 'package:house_wallet/main.dart';
import 'package:house_wallet/pages/account/notifications_page.dart';

class AccountPage extends StatelessWidget {
  const AccountPage({super.key});

  void _logout(BuildContext context) async {
    final confirm = await showDialog<bool>(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text(localizations(context).logoutDialogTitle),
              content: Text(localizations(context).logoutDialogContent),
              actions: [
                TextButton(onPressed: () => Navigator.of(context).pop<bool>(true), child: Text(localizations(context).buttonYes)),
                TextButton(onPressed: () => Navigator.of(context).pop<bool>(false), child: Text(localizations(context).buttonNo)),
              ],
            );
          },
        ) ??
        false;

    if (confirm) {
      FirebaseAuth.instance.signOut();
    }
  }

  @override
  Widget build(BuildContext context) {
    const String nome = 'Nome Cognome';

    return Scaffold(
        appBar: AppBarFix(title: Text(localizations(context).accountPage)),
        body: PadColumn(
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: SingleChildScrollView(
                  child: PadColumn(
                spacing: 8,
                children: [
                  const Row(
                    children: [
                      SizedBox(
                        width: 128,
                        height: 128,
                        child: Placeholder(),
                      ),
                      Expanded(child: Center(child: Text(nome)))
                    ],
                  ),
                  TextFormField(
                    decoration: InputDecoration(border: const OutlineInputBorder(), labelText: localizations(context).ibanInput),
                  ),
                  TextFormField(
                    decoration: InputDecoration(border: const OutlineInputBorder(), labelText: localizations(context).paypalInput),
                  ),
                  LinkListTile(
                    title: localizations(context).notificationsPage,
                    onTap: () => Navigator.of(context).push(SlidingPageRoute(const NotificationsPage())),
                  ),
                  LinkListTile(
                    title: localizations(context).changePasswordPage,
                    onTap: () => Navigator.of(context).push(SlidingPageRoute(const NotificationsPage())),
                  )
                ],
              )),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 64.0),
              child: ElevatedButton(onPressed: () => _logout(context), child: Text(localizations(context).logoutButton)),
            )
          ],
        ));
  }
}
