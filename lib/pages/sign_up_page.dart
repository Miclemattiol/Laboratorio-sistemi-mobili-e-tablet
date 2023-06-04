import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart' hide User;
import 'package:flutter/material.dart';
import 'package:flutter_series/flutter_series.dart';
import 'package:house_wallet/components/ui/app_bar_fix.dart';
import 'package:house_wallet/data/user.dart';
import 'package:house_wallet/main.dart';
import 'package:house_wallet/pages/main_page.dart';
import 'package:house_wallet/themes.dart';
import 'package:house_wallet/utils.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  bool _loading = false;

  String? _usernameValue;
  String? _emailValue;
  String? _passwordValue;
  String? _passwordConfirmValue;
  String? _ibanValue;
  String? _payPalValue;

  void _signUp() async {
    final navigator = Navigator.of(context);

    _formKey.currentState!.save();
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    try {
      final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(email: _emailValue!, password: _passwordValue!);
      navigator.pop();

      await MainPage.userFirestoreRef(credential.user!.uid).set(User(
        uid: credential.user!.uid,
        username: _usernameValue!,
        imageUrl: null,
        iban: _ibanValue,
        payPal: _payPalValue,
      ));
    } on FirebaseAuthException catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(localizations(context).actionError(error.message.toString()))));
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarFix(
        title: Text(localizations(context).signUp),
        automaticallyImplyLeading: !_loading,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: PadColumn(
            spacing: 16,
            padding: const EdgeInsets.all(16),
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                decoration: inputDecoration(localizations(context).username),
                enabled: !_loading,
                validator: (username) => username.nullTrim().isEmpty ? localizations(context).usernameMissing : null,
                onSaved: (username) => _usernameValue = username.nullTrim(),
              ),
              TextFormField(
                decoration: inputDecoration(localizations(context).email),
                enabled: !_loading,
                keyboardType: TextInputType.emailAddress,
                validator: (email) {
                  if (email == null || email.trim().isEmpty) return localizations(context).emailMissing;
                  if (!EmailValidator.validate(email.trim())) return localizations(context).emailInvalid;
                  return null;
                },
                onSaved: (email) => _emailValue = email.nullTrim(),
              ),
              TextFormField(
                decoration: inputDecoration(localizations(context).password),
                obscureText: true,
                enabled: !_loading,
                validator: (password) {
                  if (password == null || password.trim().isEmpty) return localizations(context).passwordMissing;
                  if (password != _passwordConfirmValue) return localizations(context).passwordRepeatInvalid;
                  return null;
                },
                onSaved: (password) => _passwordValue = password,
              ),
              TextFormField(
                decoration: inputDecoration(localizations(context).passwordConfirm),
                obscureText: true,
                enabled: !_loading,
                validator: (passwordConfirm) {
                  if (passwordConfirm == null || passwordConfirm.trim().isEmpty) return localizations(context).passwordMissing;
                  if (passwordConfirm != _passwordValue) return localizations(context).passwordRepeatInvalid;
                  return null;
                },
                onSaved: (passwordConfirm) => _passwordConfirmValue = passwordConfirm,
              ),
              TextFormField(
                decoration: inputDecoration("${localizations(context).iban} ${localizations(context).optional}"),
                enabled: !_loading,
                onSaved: (iban) => _ibanValue = iban.toNullable(),
              ),
              TextFormField(
                decoration: inputDecoration("${localizations(context).paypal} ${localizations(context).optional}"),
                enabled: !_loading,
                onSaved: (payPal) => _payPalValue = payPal.toNullable()?.split("/").last,
              ),
              ElevatedButton(
                onPressed: _loading ? null : _signUp,
                child: Text(localizations(context).signUp),
              ),
              SizedHeight(MediaQuery.of(context).viewPadding.bottom),
            ],
          ),
        ),
      ),
    );
  }
}
