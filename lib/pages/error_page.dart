import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_series/flutter_series.dart';
import 'package:house_wallet/main.dart';
import 'package:house_wallet/themes.dart';

class ErrorPage extends StatelessWidget {
  final String message;
  final Object? error;

  const ErrorPage({
    required this.message,
    required this.error,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: PadColumn(
            padding: const EdgeInsets.all(24),
            spacing: 16,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              centerErrorText(
                context: context,
                message: message,
                error: error,
              ),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(top: 18),
        child: FloatingActionButton(
          onPressed: FirebaseAuth.instance.signOut,
          tooltip: localizations(context).logout,
          child: const Icon(Icons.logout),
        ),
      ),
    );
  }
}
