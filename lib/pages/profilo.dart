import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:house_wallet/components/ui/app_bar_fix.dart';
import 'package:house_wallet/main.dart';

class Profilo extends StatelessWidget {
  const Profilo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarFix(title: Text(localizations(context).accountPage)),
      body: Center(
        child: ElevatedButton(onPressed: FirebaseAuth.instance.signOut, child: Text(localizations(context).logoutButton)),
      ),
    );
  }
}
