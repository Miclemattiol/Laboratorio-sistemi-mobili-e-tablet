import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_series/flutter_series.dart';
import 'package:house_wallet/main.dart';
import 'package:house_wallet/themes.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
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
    } on FirebaseAuthException catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(() {
        switch (error.code) {
          case "user-disabled":
            return localizations(context).loginErrorUserDisabled;
          case "user-not-found":
            return localizations(context).loginErrorUserNotFound;
          case "wrong-password":
            return localizations(context).loginErrorWrongPassword;
          case "too-many-requests":
            return localizations(context).loginErrorTooManyRequests;
          default:
            return error.message == null ? localizations(context).loginErrorOther : localizations(context).loginErrorOtherDetails(error.message!);
        }
      }())));
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                  decoration: inputDecoration(localizations(context).emailInput),
                  enabled: !_loading,
                  validator: (email) {
                    if (email == null || email.trim().isEmpty) return localizations(context).emailInputErrorMissing;
                    if (!EmailValidator.validate(email.trim())) return localizations(context).emailInputErrorInvalid;
                    return null;
                  },
                  keyboardType: TextInputType.emailAddress,
                  onSaved: (email) => _emailValue = email,
                ),
                TextFormField(
                  decoration: inputDecoration(localizations(context).passwordInput),
                  obscureText: true,
                  enabled: !_loading,
                  validator: (password) => (password == null || password.trim().isEmpty) ? localizations(context).passwordInputErrorMissing : null,
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
