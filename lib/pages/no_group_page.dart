import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_series/flutter_series.dart';
import 'package:house_wallet/main.dart';
import 'package:house_wallet/themes.dart';

class NoGroupPage extends StatefulWidget {
  const NoGroupPage({super.key});

  @override
  State<NoGroupPage> createState() => _NoGroupPageState();
}

class _NoGroupPageState extends State<NoGroupPage> {
  final _formKey = GlobalKey<FormState>();
  bool _loading = false;

  String? _codeValue;

  void _joinGroup() async {
    _formKey.currentState!.save();
    if (!_formKey.currentState!.validate()) return;
  }

  void _createGroup() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final appLocalizations = localizations(context);

    setState(() => _loading = true);
    try {
      /* HouseDataRef
      LoggedUser.of(context, listen: false).uid; */
    } on FirebaseException catch (error) {
      //TODO show error
      scaffoldMessenger.showSnackBar(SnackBar(content: Text("${appLocalizations.saveChangesDialogContentError}\n(${error.message})")));
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
              padding: const EdgeInsets.all(24),
              spacing: 16,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(localizations(context).noGroupPageTitle, textAlign: TextAlign.center, style: Theme.of(context).textTheme.headlineSmall),
                Text(localizations(context).noGroupPageContent, textAlign: TextAlign.center),
                TextFormField(
                  decoration: inputDecoration(localizations(context).noGroupPageCodeInput).copyWith(suffixIcon: const Icon(Icons.send)),
                  enabled: !_loading,
                  validator: (code) => (code ?? "").trim().isEmpty ? localizations(context).noGroupPageCodeInputErrorMissing : null,
                  onSaved: (code) => _codeValue = code,
                  onEditingComplete: _loading ? null : _joinGroup,
                ),
                Text(localizations(context).noGroupPageContentOr, textAlign: TextAlign.center),
                ElevatedButton(
                  onPressed: _loading ? null : _createGroup,
                  child: Text(localizations(context).noGroupPageNewHouseButton),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
      floatingActionButton: FloatingActionButton(onPressed: _loading ? null : FirebaseAuth.instance.signOut, child: const Icon(Icons.logout)),
    );
  }
}
