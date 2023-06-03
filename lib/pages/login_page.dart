import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_series/flutter_series.dart';
import 'package:house_wallet/components/login/app_icon.dart';
import 'package:house_wallet/components/ui/sliding_page_route.dart';
import 'package:house_wallet/main.dart';
import 'package:house_wallet/pages/sign_up_page.dart';
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

  //TODO add test app functionality with demo values?
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
        key: _formKey,
        child: Center(
          child: SingleChildScrollView(
            child: PadColumn(
              spacing: 24,
              padding: const EdgeInsets.all(16),
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const AppIcon(),
                PadColumn(
                  spacing: 8,
                  children: [
                    TextFormField(
                      decoration: inputDecoration(localizations(context).email),
                      enabled: !_loading,
                      keyboardType: TextInputType.emailAddress,
                      validator: (email) {
                        if (email == null || email.trim().isEmpty) return localizations(context).emailMissing;
                        if (!EmailValidator.validate(email.trim())) return localizations(context).emailInvalid;
                        return null;
                      },
                      onSaved: (email) => _emailValue = (email ?? "").trim(),
                    ),
                    TextFormField(
                      decoration: inputDecoration(localizations(context).password),
                      obscureText: true,
                      enabled: !_loading,
                      validator: (password) => (password == null || password.trim().isEmpty) ? localizations(context).passwordMissing : null,
                      onSaved: (password) => _passwordValue = password,
                      onEditingComplete: _loading ? null : _login,
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ElevatedButton(
                      onPressed: _loading ? null : _login,
                      child: Text(localizations(context).signIn),
                    ),
                    ElevatedButton(
                      onPressed: _loading ? null : () => Navigator.of(context).push(SlidingPageRoute(const SignUpPage())),
                      child: Text(localizations(context).signUp),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
