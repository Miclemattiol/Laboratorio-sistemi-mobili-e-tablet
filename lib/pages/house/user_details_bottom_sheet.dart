import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_series/flutter_series.dart';
import 'package:house_wallet/components/image_picker_bottom_sheet.dart';
import 'package:house_wallet/components/ui/custom_bottom_sheet.dart';
import 'package:house_wallet/components/ui/custom_dialog.dart';
import 'package:house_wallet/components/ui/image_avatar.dart';
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

  Future<void> _handleUserLeaving(String uid) async {
    final userBalance = house.getBalance(uid);
    final otherUser = () {
      if (userBalance < 0) {
        return house.balances.entries.reduce((prev, element) => element.value > prev.value ? element : prev).key;
      } else {
        return house.balances.entries.reduce((prev, element) => element.value < prev.value ? element : prev).key;
      }
    }();

    return house.reference.update({
      "${HouseData.usersKey}.$uid": FieldValue.delete(),
      if (userBalance != 0) "${HouseData.usersKey}.$otherUser": house.getBalance(otherUser) + userBalance,
    });
  }

  void _leave(BuildContext context) async {
    final navigator = Navigator.of(context);
    final isOwner = loggedUser.uid == house.owner.uid;
    final isLastUser = house.users.length == 1;
    final canLeave = !isOwner || isLastUser;

    if (!canLeave) {
      return CustomDialog.alert(
        context: context,
        title: localizations(context).error,
        content: localizations(context).userLeaveNotAllowed,
      );
    }

    if (!await CustomDialog.confirm(
      context: context,
      title: localizations(context).userLeaveTitle,
      content: isLastUser ? localizations(context).userLeaveLastUser : localizations(context).userLeaveContent,
    )) return;

    try {
      if (isLastUser) {
        await house.reference.delete(); //TODO check
      } else {
        await _handleUserLeaving(loggedUser.uid);
      }
      navigator.pop();
    } on FirebaseException catch (error) {
      if (context.mounted) {
        CustomDialog.alert(
          context: context,
          title: localizations(context).error,
          content: localizations(context).actionError(error.message.toString()),
        );
      }
    }
  }

  void _kick(BuildContext context) async {
    final navigator = Navigator.of(context);

    if (!await CustomDialog.confirm(
      context: context,
      title: localizations(context).userKickTitle,
      content: localizations(context).userKickContent(user.username),
    )) return;

    try {
      await _handleUserLeaving(user.uid);
      navigator.pop();
    } on FirebaseException catch (error) {
      if (context.mounted) {
        CustomDialog.alert(
          context: context,
          title: localizations(context).error,
          content: localizations(context).actionError(error.message.toString()),
        );
      }
    }
  }

  void _transfer(BuildContext context) async {
    final navigator = Navigator.of(context);

    if (!await CustomDialog.confirm(
      context: context,
      title: localizations(context).userTransferTitle,
      content: localizations(context).userTransferContent(user.username),
    )) return;

    try {
      await house.reference.update({
        HouseData.ownerKey: user.uid,
      });
      navigator.pop();
    } on FirebaseException catch (error) {
      if (context.mounted) {
        CustomDialog.alert(
          context: context,
          title: localizations(context).error,
          content: localizations(context).actionError(error.message.toString()),
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
            ImageAvatar(user.imageUrl, fallback: const Icon(Icons.person), onTap: user.imageUrl != null ? () => ImagePage.openImage(context, user.imageUrl) : null),
            Text(user.username),
          ],
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(() {
            final balance = house.getBalance(user.uid);
            return localizations(context).userBalance("${balance > 0 ? "+" : ""}${currencyFormat(context).format(balance)}");
          }()),
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
