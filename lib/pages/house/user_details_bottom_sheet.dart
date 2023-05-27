import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_series/flutter_series.dart';
import 'package:house_wallet/components/ui/custom_bottom_sheet.dart';
import 'package:house_wallet/components/ui/custom_dialog.dart';
import 'package:house_wallet/components/ui/user_avatar.dart';
import 'package:house_wallet/data/house_data.dart';
import 'package:house_wallet/data/logged_user.dart';
import 'package:house_wallet/data/user.dart';
import 'package:house_wallet/main.dart';
import 'package:house_wallet/pages/house/send_money_dialog.dart';

class UserDetailsBottomSheet extends StatelessWidget {
  final User user;
  final LoggedUser loggedUser;
  final HouseDataRef house;

  const UserDetailsBottomSheet(
    this.user, {
    required this.loggedUser,
    required this.house,
    super.key,
  });

  void _leave(BuildContext context) async {
    final navigator = Navigator.of(context);
    final isOwner = loggedUser.uid == house.owner.uid;
    final isLastUser = house.users.length == 1;
    final canLeave = !isOwner || isLastUser;

    if (!canLeave) {
      return CustomDialog.alert(
        context: context,
        title: localizations(context).error,
        content: localizations(context).leaveDialogContentNotAllowed,
      );
    }

    if (!await CustomDialog.confirm(
      context: context,
      title: localizations(context).leaveConfirmDialogTitle,
      content: isLastUser ? localizations(context).leaveConfirmDialogContentLastUser : localizations(context).leaveConfirmDialogContent,
    )) return;

    try {
      if (isLastUser) {
        await house.reference.delete();
      } else {
        await house.reference.update({
          "users": FieldValue.arrayRemove([
            loggedUser.uid
          ])
        });
      }
      navigator.pop();
    } on FirebaseException catch (error) {
      if (context.mounted) {
        CustomDialog.alert(
          context: context,
          title: localizations(context).error,
          content: "${localizations(context).userDialogContentError} (${error.message})",
        );
      }
    }
  }

  void _kick(BuildContext context) async {
    final navigator = Navigator.of(context);

    if (!await CustomDialog.confirm(
      context: context,
      title: localizations(context).kickConfirmDialogTitle,
      content: localizations(context).kickConfirmDialogContent(user.username),
    )) return;

    try {
      await house.reference.update({
        "users": FieldValue.arrayRemove([
          user.uid
        ])
      });
      navigator.pop();
    } on FirebaseException catch (error) {
      if (context.mounted) {
        CustomDialog.alert(
          context: context,
          title: localizations(context).error,
          content: "${localizations(context).userDialogContentError} (${error.message})",
        );
      }
    }
  }

  void _transfer(BuildContext context) async {
    final navigator = Navigator.of(context);

    if (!await CustomDialog.confirm(
      context: context,
      title: localizations(context).transferConfirmDialogTitle,
      content: localizations(context).transferConfirmDialogContent(user.username),
    )) return;

    try {
      await house.reference.update({
        "owner": user.uid
      });
      navigator.pop();
    } on FirebaseException catch (error) {
      if (context.mounted) {
        CustomDialog.alert(
          context: context,
          title: localizations(context).error,
          content: "${localizations(context).userDialogContentError} (${error.message})",
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomBottomSheet(
      body: [
        PadRow(
          spacing: 16,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            ImageAvatar(user.imageUrl, fallback: const Icon(Icons.person)),
            Text(user.username),
          ],
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(localizations(context).userBalance(currencyFormat(context).format(10))), //TODO balance
        ),
        if (loggedUser.uid == user.uid) ...[
          ElevatedButton(
            onPressed: () => _leave(context),
            style: ElevatedButton.styleFrom(tapTargetSize: MaterialTapTargetSize.shrinkWrap),
            child: Text(localizations(context).userLeave),
          ),
        ] else ...[
          ElevatedButton(
            onPressed: () async {
              final navigator = Navigator.of(context);
              if (await showDialog(context: context, builder: (context) => SendMoneyDialog(user, loggedUser: loggedUser, house: house)) != null) navigator.pop();
            },
            style: ElevatedButton.styleFrom(tapTargetSize: MaterialTapTargetSize.shrinkWrap),
            child: Text(localizations(context).userSendMoney),
          ),
          if (loggedUser.uid == house.owner.uid) ...[
            ElevatedButton(
              onPressed: () => _kick(context),
              style: ElevatedButton.styleFrom(tapTargetSize: MaterialTapTargetSize.shrinkWrap),
              child: Text(localizations(context).userKick),
            ),
            ElevatedButton(
              onPressed: () => _transfer(context),
              style: ElevatedButton.styleFrom(tapTargetSize: MaterialTapTargetSize.shrinkWrap),
              child: Text(localizations(context).userTransfer),
            )
          ],
        ]
      ],
    );
  }
}
