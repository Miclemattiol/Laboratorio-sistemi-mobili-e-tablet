import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_series/flutter_series.dart';
import 'package:house_wallet/data/house_data.dart';
import 'package:house_wallet/data/logged_user.dart';
import 'package:house_wallet/main.dart';
import 'package:house_wallet/themes.dart';
import 'package:house_wallet/utils.dart';

class NoHousePage extends StatefulWidget {
  const NoHousePage({super.key});

  @override
  State<NoHousePage> createState() => _NoHousePageState();
}

class _NoHousePageState extends State<NoHousePage> {
  final _formKey = GlobalKey<FormState>();
  bool _loading = false;

  String? _codeValue;

  void _joinGroup() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final appLocalizations = localizations(context);

    _formKey.currentState!.save();
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    try {
      final myUid = LoggedUser.of(context, listen: false).uid;
      final groups = (await App.groupsFirestoreReference.where(HouseData.codesKey, arrayContains: _codeValue!).limit(1).get()).docs;

      if (groups.isEmpty) {
        scaffoldMessenger.showSnackBar(SnackBar(content: Text(appLocalizations.groupCodeInvalid), duration: const Duration(seconds: 6)));
        setState(() => _loading = false);
        return;
      }

      await App.groupsFirestoreReference.doc(groups.first.id).update({
        HouseData.codesKey: FieldValue.arrayRemove([_codeValue]),
        "${HouseData.usersKey}.$myUid": 0,
      });
    } on FirebaseException catch (error) {
      if (!mounted) return;
      scaffoldMessenger.showSnackBar(SnackBar(content: Text(appLocalizations.actionError(error.message.toString()))));
      setState(() => _loading = false);
    }
  }

  void _createGroup() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final appLocalizations = localizations(context);

    setState(() => _loading = true);
    try {
      final myUid = LoggedUser.of(context, listen: false).uid;

      await App.groupsFirestoreReference.add(HouseData(
        owner: myUid,
        users: {myUid: 0},
        codes: [],
      ));
    } on FirebaseException catch (error) {
      if (!mounted) return;
      scaffoldMessenger.showSnackBar(SnackBar(content: Text(appLocalizations.actionError(error.message.toString()))));
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
                Text(localizations(context).noHousePageTitle, textAlign: TextAlign.center, style: Theme.of(context).textTheme.headlineSmall),
                Text(localizations(context).noHousePageContent, textAlign: TextAlign.center),
                TextFormField(
                  decoration: inputDecoration(localizations(context).groupCode).copyWith(
                    suffixIcon: GestureDetector(onTap: _loading ? null : _joinGroup, child: const Icon(Icons.send)),
                  ),
                  enabled: !_loading,
                  validator: (code) => code.nullTrim().isEmpty ? localizations(context).groupCodeMissing : null,
                  onSaved: (code) => _codeValue = code,
                  onEditingComplete: _loading ? null : _joinGroup,
                ),
                Text(localizations(context).noHousePageContentOr, textAlign: TextAlign.center),
                ElevatedButton(
                  onPressed: _loading ? null : _createGroup,
                  child: Text(localizations(context).createNewHouse),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(top: 18),
        child: FloatingActionButton(
          onPressed: _loading ? null : FirebaseAuth.instance.signOut,
          tooltip: localizations(context).signOut,
          child: const Icon(Icons.logout),
        ),
      ),
    );
  }
}
