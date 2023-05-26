import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_series/flutter_series.dart';
import 'package:house_wallet/components/ui/app_bar_fix.dart';
import 'package:house_wallet/components/ui/custom_dialog.dart';
import 'package:house_wallet/components/ui/dropdown_list_tile.dart';
import 'package:house_wallet/components/ui/sliding_page_route.dart';
import 'package:house_wallet/components/ui/user_avatar.dart';
import 'package:house_wallet/data/firestore.dart';
import 'package:house_wallet/data/logged_user.dart';
import 'package:house_wallet/image_picker.dart';
import 'package:house_wallet/main.dart';
import 'package:house_wallet/pages/account/notifications_page.dart';
import 'package:house_wallet/themes.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  final _formKey = GlobalKey<FormState>();
  bool _edited = false;
  bool _loading = false;
  double? _uploadProgress;

  String? _ibanValue;
  String? _payPalValue;

  void _changeProfilePicture(String? currentImage) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final appLocalizations = localizations(context);

    final image = await pickImage(context);
    if (image == null) return;

    final upload = FirebaseStorage.instance.ref("users/${LoggedUser.uid}-${DateTime.now().millisecondsSinceEpoch}.png").putFile(image);

    setState(() => _uploadProgress = null);
    upload.snapshotEvents.listen((event) => setState(() => _uploadProgress = event.bytesTransferred / event.totalBytes));

    try {
      final imageUrl = await (await upload).ref.getDownloadURL();
      setState(() => _uploadProgress = null);

      await FirestoreData.userFirestoreRef(LoggedUser.uid!).update({
        "imageUrl": imageUrl
      });

      if (currentImage != null) {
        try {
          await FirebaseStorage.instance.refFromURL(currentImage).delete();
        } catch (_) {}
      }
    } on FirebaseException catch (error) {
      scaffoldMessenger.showSnackBar(SnackBar(content: Text("${appLocalizations.saveChangesDialogContentError}\n(${error.message})")));
      setState(() => _uploadProgress = null);
    }
  }

  void _changeUsername(String currentUsername) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final appLocalizations = localizations(context);

    final username = await CustomDialog.prompt(
      context: context,
      title: localizations(context).changeUsernameDialogTitle,
      inputLabel: localizations(context).usernameInput,
      initialValue: currentUsername,
      onSaved: (newValue) => newValue?.trim(),
      validator: (value) => (value ?? "").trim().isEmpty ? localizations(context).usernameInputErrorMissing : null,
    );
    if (username == null || username == currentUsername) return;

    try {
      await FirestoreData.userFirestoreRef(LoggedUser.uid!).update({
        "username": username,
      });

      scaffoldMessenger.showSnackBar(SnackBar(content: Text(appLocalizations.saveChangesDialogContent)));
    } on FirebaseException catch (error) {
      scaffoldMessenger.showSnackBar(SnackBar(content: Text("${appLocalizations.saveChangesDialogContentError}\n(${error.message})")));
    }
  }

  void _saveChanges() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final appLocalizations = localizations(context);

    _formKey.currentState!.save();

    try {
      await FirestoreData.userFirestoreRef(LoggedUser.uid!).update({
        "iban": _ibanValue,
        "payPal": _payPalValue
      });

      _edited = false;
      scaffoldMessenger.showSnackBar(SnackBar(content: Text(appLocalizations.saveChangesDialogContent)));
    } on FirebaseException catch (error) {
      scaffoldMessenger.showSnackBar(SnackBar(content: Text("${appLocalizations.saveChangesDialogContentError}\n(${error.message})")));
    } finally {
      setState(() => _loading = false);
    }
  }

  void _discardChanges() {
    _formKey.currentState!.reset();
    setState(() => _edited = false);
  }

  void _changePassword() async {
    if (!await CustomDialog.confirm(
      context: context,
      title: localizations(context).changePasswordDialogTitle,
      content: localizations(context).changePasswordDialogContent,
    )) return;

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: LoggedUser.user!.email!);

      if (mounted) {
        CustomDialog.alert(
          context: context,
          title: localizations(context).changePasswordDialogTitle,
          content: localizations(context).changePasswordDialogContentSendSuccess,
        );
      }
    } on FirebaseAuthException catch (error) {
      if (mounted) {
        CustomDialog.alert(
          context: context,
          title: localizations(context).changePasswordDialogTitle,
          content: "${localizations(context).changePasswordDialogContentSendError}\n(${error.message})",
        );
      }
    }
  }

  void _logout() async {
    if (!await CustomDialog.confirm(
      context: context,
      title: localizations(context).logoutDialogTitle,
      content: localizations(context).logoutDialogContent,
    )) return;

    FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Scaffold(
        appBar: AppBarFix(
          title: Text(localizations(context).accountPage),
          actions: _edited
              ? [
                  IconButton(
                    onPressed: _discardChanges,
                    icon: const Icon(Icons.undo),
                    tooltip: localizations(context).discardChangesTooltip,
                  ),
                  IconButton(
                    onPressed: _saveChanges,
                    icon: const Icon(Icons.save),
                    tooltip: localizations(context).saveChangesTooltip,
                  )
                ]
              : null,
        ),
        body: StreamBuilder(
          stream: FirestoreData.userFirestoreRef(LoggedUser.uid!).snapshots().map((doc) => doc.data()),
          builder: (context, snapshot) {
            final user = snapshot.data;

            if (user == null) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Shimmer.fromColors(
                  baseColor: Theme.of(context).disabledColor,
                  highlightColor: Theme.of(context).disabledColor.withOpacity(.1),
                  child: Column(
                    children: [
                      PadColumn(
                        spacing: 16,
                        padding: const EdgeInsets.all(16),
                        children: [
                          PadRow(
                            spacing: 16,
                            children: [
                              Container(width: 128, height: 128, decoration: ImageAvatar.border(context).copyWith(color: Colors.white)),
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(padding: const EdgeInsets.only(bottom: 8), child: Container(width: 128, height: 32, color: Colors.white)),
                                    Container(width: 64, height: 16, color: Colors.white),
                                  ],
                                ),
                              )
                            ],
                          ),
                          Container(width: double.infinity, height: 48, color: Colors.white),
                          Container(width: double.infinity, height: 48, color: Colors.white),
                          Container(width: double.infinity, height: 48, color: Colors.white),
                          Container(width: double.infinity, height: 48, color: Colors.white),
                        ],
                      ),
                    ],
                  ),
                );
              } else {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      "${localizations(context).accountPageError} (${snapshot.error})",
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ),
                );
              }
            }

            return ListView(
              children: [
                PadColumn(
                  spacing: 16,
                  padding: const EdgeInsets.all(16),
                  children: [
                    PadRow(
                      spacing: 16,
                      children: [
                        Stack(
                          children: [
                            GestureDetector(
                              onTap: () => _changeProfilePicture(user.imageUrl),
                              child: ImageAvatar(user.imageUrl, fallback: const Icon(Icons.person), size: 128),
                            ),
                            if (_uploadProgress != null)
                              Container(
                                width: 128,
                                height: 128,
                                clipBehavior: Clip.antiAlias,
                                decoration: ImageAvatar.border(context).copyWith(color: Colors.black26),
                                child: Padding(
                                  padding: const EdgeInsets.all(48),
                                  child: CircularProgressIndicator(value: _uploadProgress),
                                ),
                              )
                          ],
                        ),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              FittedBox(
                                fit: BoxFit.fitWidth,
                                child: Row(
                                  children: [
                                    Text(user.username, style: Theme.of(context).textTheme.headlineMedium),
                                    IconButton(
                                      icon: const Icon(Icons.edit),
                                      tooltip: localizations(context).changeUsernameDialogTitle,
                                      onPressed: () => _changeUsername(user.username),
                                    )
                                  ],
                                ),
                              ),
                              Text(LoggedUser.user!.email!),
                            ],
                          ),
                        )
                      ],
                    ),
                    TextFormField(
                      initialValue: user.iban,
                      decoration: inputDecoration(localizations(context).ibanInput),
                      enabled: !_loading,
                      onChanged: (_) {
                        if (!_edited) setState(() => _edited = true);
                      },
                      onSaved: (iban) => _ibanValue = (iban ?? "").trim().isEmpty ? null : iban?.trim(),
                    ),
                    TextFormField(
                      initialValue: user.payPal,
                      decoration: inputDecoration(localizations(context).paypalInput),
                      enabled: !_loading,
                      onChanged: (_) {
                        if (!_edited) setState(() => _edited = true);
                      },
                      onSaved: (payPal) => _payPalValue = (payPal ?? "").trim().isEmpty ? null : payPal?.trim(),
                    ),
                  ],
                ),
                ListTile(
                  title: Text(localizations(context).notificationsPage),
                  onTap: () => Navigator.of(context).push(SlidingPageRoute(const NotificationsPage())),
                  trailing: const Icon(Icons.keyboard_arrow_right),
                ),
                Consumer<ThemeNotifier>(
                  builder: (context, themeNotifier, _) => DropdownListTile<ThemeMode>(
                    initialValue: themeNotifier.value,
                    title: Text(localizations(context).themeInput),
                    values: [
                      DropdownMenuItem(value: ThemeMode.system, child: Text(localizations(context).themeDevice)),
                      DropdownMenuItem(value: ThemeMode.light, child: Text(localizations(context).themeLight)),
                      DropdownMenuItem(value: ThemeMode.dark, child: Text(localizations(context).themeDark))
                    ],
                    onChanged: (newValue) => themeNotifier.value = newValue,
                  ),
                ),
                ListTile(
                  title: Text(localizations(context).changePasswordDialogTitle),
                  onTap: _changePassword,
                ),
                ListTile(
                  title: Text(localizations(context).logoutDialogTitle),
                  onTap: _logout,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
