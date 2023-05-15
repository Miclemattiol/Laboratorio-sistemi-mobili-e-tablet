import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_series/flutter_series.dart';
import 'package:house_wallet/components/ui/app_bar_fix.dart';
import 'package:house_wallet/main.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _formKey = GlobalKey<FormState>();
  bool _loading = false;

  String? _emailValue;
  String? _passwordValue;

  void _login() async {
    _formKey.currentState!.save();
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(email: _emailValue!, password: _passwordValue!);
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(() {
        switch (e.code) {
          case "user-disabled":
            return localizations(context).errorUserDisabled;
          case "user-not-found":
            return localizations(context).errorUserNotFound;
          case "wrong-password":
            return localizations(context).errorWrongPassword;
          case "too-many-requests":
            return localizations(context).errorTooManyRequests;
          default:
            return e.message == null ? localizations(context).errorOther : localizations(context).errorOtherDetails(e.message!);
        }
      }())));
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarFix(title: Text(localizations(context).loginPage)),
      body: Form(
        key: _formKey,
        child: Center(
          child: SingleChildScrollView(
            child: PadColumn(
              padding: const EdgeInsets.all(16),
              spacing: 16,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset("assets/logo.png", width: 200),
                TextFormField(
                  decoration: InputDecoration(border: const OutlineInputBorder(), labelText: localizations(context).emailInput),
                  enabled: !_loading,
                  validator: (email) {
                    if (email == null || email.trim().isEmpty) return localizations(context).errorMissingEmail;
                    if (!EmailValidator.validate(email.trim())) return localizations(context).errorInvalidEmail;
                    return null;
                  },
                  onSaved: (email) => _emailValue = email,
                ),
                TextFormField(
                  decoration: InputDecoration(border: const OutlineInputBorder(), labelText: localizations(context).passwordInput),
                  enabled: !_loading,
                  validator: (password) => (password == null || password.trim().isEmpty) ? localizations(context).errorMissingPassword : null,
                  onSaved: (password) => _passwordValue = password,
                ),
                ElevatedButton(
                  onPressed: _loading ? null : _login,
                  child: Text(localizations(context).loginButton),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
