import 'package:firebase_auth/firebase_auth.dart' hide User;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_series/flutter_series.dart';
import 'package:house_wallet/components/image_picker_bottom_sheet.dart';
import 'package:house_wallet/components/ui/app_bar_fix.dart';
import 'package:house_wallet/components/ui/custom_dialog.dart';
import 'package:house_wallet/components/ui/dropdown_list_tile.dart';
import 'package:house_wallet/components/ui/image_avatar.dart';
import 'package:house_wallet/components/ui/sliding_page_route.dart';
import 'package:house_wallet/data/logged_user.dart';
import 'package:house_wallet/data/user.dart';
import 'package:house_wallet/main.dart';
import 'package:house_wallet/pages/account/notifications_page.dart';
import 'package:house_wallet/pages/main_page.dart';
import 'package:house_wallet/themes.dart';
import 'package:house_wallet/utils.dart';
import 'package:provider/provider.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  late final loggedUser = LoggedUser.of(context);
  final _formKey = GlobalKey<FormState>();
  bool _edited = false;
  bool _loading = false;
  double? _uploadProgress;

  String? _ibanValue;
  String? _payPalValue;

  void _changeProfilePicture(String? currentImage) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final appLocalizations = localizations(context);

    final image = await ImagePickerBottomSheet.pickImage(context, image: currentImage);
    if (image == null) return;

    final upload = FirebaseStorage.instance.ref("users/${loggedUser.uid}-${DateTime.now().millisecondsSinceEpoch}.png").putFile(image);

    setState(() => _uploadProgress = null);
    upload.snapshotEvents.listen((event) => setState(() => _uploadProgress = event.bytesTransferred / event.totalBytes));

    try {
      final imageUrl = await (await upload).ref.getDownloadURL();
      setState(() => _uploadProgress = null);

      await MainPage.userFirestoreRef(loggedUser.uid).update({
        User.imageUrlKey: imageUrl
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
      await MainPage.userFirestoreRef(loggedUser.uid).update({
        User.usernameKey: username,
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
      await MainPage.userFirestoreRef(loggedUser.uid).update({
        User.ibanKey: _ibanValue,
        User.payPalKey: _payPalValue,
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
      await FirebaseAuth.instance.sendPasswordResetEmail(email: loggedUser.authUser.email!);

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
    final user = loggedUser.getUserData(context);
    return Form(
      key: _formKey,
      child: Scaffold(
        appBar: AppBarFix(
          title: Text(localizations(context).accountPage),
          actions: [
            IconButton(
              onPressed: _edited ? _discardChanges : null,
              icon: const Icon(Icons.undo),
              tooltip: localizations(context).discardChangesTooltip,
            ),
            IconButton(
              onPressed: _edited ? _saveChanges : null,
              icon: const Icon(Icons.save),
              tooltip: localizations(context).saveChangesTooltip,
            )
          ],
        ),
        body: ListView(
          children: [
            PadColumn(
              spacing: 16,
              padding: const EdgeInsets.all(16),
              children: [
                PadRow(
                  spacing: 16,
                  children: [
                    ImageAvatar(
                      user.imageUrl,
                      fallback: const Icon(Icons.person),
                      size: 128,
                      onTap: () => _changeProfilePicture(user.imageUrl),
                      progress: _uploadProgress,
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
                          Text(loggedUser.authUser.email!),
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
                  onSaved: (iban) => _ibanValue = iban.toNullable(),
                ),
                TextFormField(
                  initialValue: user.payPal,
                  decoration: inputDecoration(localizations(context).paypalInput),
                  enabled: !_loading,
                  onChanged: (_) {
                    if (!_edited) setState(() => _edited = true);
                  },
                  onSaved: (payPal) => _payPalValue = payPal.toNullable()?.split("/").last,
                ),
              ],
            ),
            ListTile(
              title: Text(localizations(context).notificationsPage),
              onTap: () => Navigator.of(context).push(SlidingPageRoute(const NotificationsPage())),
              trailing: const Icon(Icons.keyboard_arrow_right),
            ),
            Consumer<ThemeNotifier>(builder: (context, themeNotifier, _) {
              return DropdownListTile<ThemeMode>(
                initialValue: themeNotifier.value,
                title: Text(localizations(context).themeInput),
                values: [
                  DropdownMenuItem(value: ThemeMode.system, child: Text(localizations(context).themeDevice)),
                  DropdownMenuItem(value: ThemeMode.light, child: Text(localizations(context).themeLight)),
                  DropdownMenuItem(value: ThemeMode.dark, child: Text(localizations(context).themeDark))
                ],
                onChanged: (newValue) => themeNotifier.value = newValue,
              );
            }),
            ListTile(
              title: Text(localizations(context).changePasswordDialogTitle),
              onTap: _changePassword,
            ),
            ListTile(
              title: Text(localizations(context).logoutDialogTitle),
              onTap: _logout,
            ),
          ],
        ),
      ),
    );
  }
}
