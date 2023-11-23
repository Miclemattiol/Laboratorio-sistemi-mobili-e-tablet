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
import 'package:house_wallet/pages/account/payment_methods_page.dart';
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
  double? _uploadProgress;

  void _changeProfilePicture(String? currentImage) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final appLocalizations = localizations(context);

    final image = await ImagePickerBottomSheet.pickImage(context, image: currentImage);
    if (image == null || !mounted) return;

    if (await isNotConnectedToInternet(context) || !mounted) return;

    final upload = FirebaseStorage.instance.ref("users/${loggedUser.uid}-${DateTime.now().millisecondsSinceEpoch}.png").putFile(image);

    setState(() => _uploadProgress = null);
    upload.snapshotEvents.listen((event) => setState(() => _uploadProgress = event.bytesTransferred / event.totalBytes));

    try {
      final imageUrl = await (await upload).ref.getDownloadURL();
      setState(() => _uploadProgress = null);

      await MainPage.userFirestoreRef(loggedUser.uid).update({
        User.imageUrlKey: imageUrl,
      });

      if (currentImage != null) {
        try {
          await FirebaseStorage.instance.refFromURL(currentImage).delete();
        } catch (_) {}
      }
    } on FirebaseException catch (error) {
      scaffoldMessenger.showSnackBar(SnackBar(content: Text(appLocalizations.saveChangesError(error.message.toString()))));
      setState(() => _uploadProgress = null);
    }
  }

  void _changeUsername(String currentUsername) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final appLocalizations = localizations(context);

    if (await isNotConnectedToInternet(context) || !mounted) return;

    final username = await CustomDialog.prompt(
      context: context,
      title: localizations(context).changeUsernameTitle,
      inputDecoration: inputDecoration(localizations(context).username),
      initialValue: currentUsername,
      onSaved: (username) => username?.trim(),
      validator: (username) => username.nullTrim().isEmpty ? localizations(context).usernameMissing : null,
    );
    if (username == null || username == currentUsername) return;

    try {
      await MainPage.userFirestoreRef(loggedUser.uid).update({
        User.usernameKey: username,
      });

      scaffoldMessenger.showSnackBar(SnackBar(content: Text(appLocalizations.saveChangesSuccess)));
    } on FirebaseException catch (error) {
      scaffoldMessenger.showSnackBar(SnackBar(content: Text(appLocalizations.saveChangesError(error.message.toString()))));
    }
  }

  void _changePassword() async {
    if (await isNotConnectedToInternet(context) || !context.mounted) return;

    if (!await CustomDialog.confirm(
      context: context,
      title: localizations(context).changePasswordTitle,
      content: localizations(context).changePasswordContent,
    )) return;

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: loggedUser.authUser.email!);

      if (mounted) {
        CustomDialog.alert(
          context: context,
          title: localizations(context).changePasswordTitle,
          content: localizations(context).changePasswordSuccess,
        );
      }
    } on FirebaseAuthException catch (error) {
      if (mounted) {
        CustomDialog.alert(
          context: context,
          title: localizations(context).changePasswordTitle,
          content: localizations(context).changePasswordError(error.message.toString()),
        );
      }
    }
  }

  void _logout() async {
    if (!await CustomDialog.confirm(
      context: context,
      title: localizations(context).signOut,
      content: localizations(context).logoutConfirm,
    )) return;

    FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    final user = loggedUser.getUserData(context);
    return Scaffold(
      appBar: AppBarFix(
        title: Text(localizations(context).accountPage),
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
                    fallback: (enabled) => Icon(Icons.person, color: enabled ? null : Theme.of(context).disabledColor),
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
                                tooltip: localizations(context).changeUsernameTitle,
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
            ],
          ),
          ListTile(
            title: Text(localizations(context).paymentMethods),
            onTap: () => Navigator.of(context).push(SlidingPageRoute(PaymentMethodsPage(
              loggedUser: loggedUser,
              user: user,
            ))),
            trailing: const Icon(Icons.keyboard_arrow_right),
          ),
          ListTile(
            title: Text(localizations(context).notificationsPage),
            onTap: () => Navigator.of(context).push(SlidingPageRoute(const NotificationsPage())),
            trailing: const Icon(Icons.keyboard_arrow_right),
          ),
          Consumer<ThemeNotifier>(builder: (context, themeNotifier, _) {
            return DropdownListTile<ThemeMode>(
              initialValue: themeNotifier.value,
              title: Text(localizations(context).theme),
              values: [
                DropdownMenuItem(value: ThemeMode.system, child: Text(localizations(context).themeDevice)),
                DropdownMenuItem(value: ThemeMode.light, child: Text(localizations(context).themeLight)),
                DropdownMenuItem(value: ThemeMode.dark, child: Text(localizations(context).themeDark)),
              ],
              onChanged: (newValue) => themeNotifier.value = newValue,
            );
          }),
          ListTile(
            title: Text(localizations(context).changePasswordTitle),
            onTap: _changePassword,
          ),
          ListTile(
            title: Text(localizations(context).signOut),
            onTap: _logout,
          ),
        ],
      ),
    );
  }
}
