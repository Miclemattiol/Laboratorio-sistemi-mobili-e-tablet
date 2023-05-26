import 'package:flutter/material.dart';
import 'package:flutter_series/flutter_series.dart';
import 'package:house_wallet/components/ui/custom_bottom_sheet.dart';
import 'package:house_wallet/components/ui/custom_dialog.dart';
import 'package:house_wallet/components/ui/user_avatar.dart';
import 'package:house_wallet/data/logged_user.dart';
import 'package:house_wallet/data/user.dart';
import 'package:house_wallet/main.dart';
import 'package:house_wallet/pages/house/send_money_dialog.dart';

class UserDetailsBottomSheet extends StatelessWidget {
  final User user;

  const UserDetailsBottomSheet(
    this.user, {
    super.key,
  });

  void _leave(BuildContext context) async {
    //TODO allow only if not the owner or if only user of the house (show a message dialog otherwise)
    final canLeave = (() => true)();
    final lastUser = (() => false)();

    if (!canLeave) {
      return CustomDialog.alert(
        context: context,
        title: localizations(context).error,
        content: localizations(context).leaveErrorDialogContent,
      );
    }

    if (!await CustomDialog.confirm(
      context: context,
      title: localizations(context).leaveConfirmDialogTitle,
      content: lastUser ? localizations(context).leaveConfirmDialogContentLastUser : localizations(context).leaveConfirmDialogContent,
    )) return;

    //TODO leave house
    if (context.mounted) {
      CustomDialog.alert(
        context: context,
        title: "TODO",
        content: "Leave house...",
      );
    }
    /* house.leave();
    if(lastUser) {
      house.delete();
    } */
  }

  void _kick(BuildContext context) async {
    if (!await CustomDialog.confirm(
      context: context,
      title: localizations(context).kickConfirmDialogTitle,
      content: localizations(context).kickConfirmDialogContent(user.username),
    )) return;

    //TODO kick user
    if (context.mounted) {
      CustomDialog.alert(
        context: context,
        title: "TODO",
        content: "Kick user...",
      );
    }
  }

  void _transfer(BuildContext context) async {
    if (!await CustomDialog.confirm(
      context: context,
      title: localizations(context).transferConfirmDialogTitle,
      content: localizations(context).transferConfirmDialogContent(user.username),
    )) return;

    //TODO transfer ownership
    if (context.mounted) {
      CustomDialog.alert(
        context: context,
        title: "TODO",
        content: "Transfer ownership...",
      );
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
        if (user.uid == LoggedUser.uid) ...[
          ElevatedButton(
            onPressed: () => _leave(context),
            style: ElevatedButton.styleFrom(tapTargetSize: MaterialTapTargetSize.shrinkWrap),
            child: Text(localizations(context).userLeave),
          ),
        ] else ...[
          ElevatedButton(
            onPressed: () => showDialog(context: context, builder: (context) => SendMoneyDialog(user)),
            style: ElevatedButton.styleFrom(tapTargetSize: MaterialTapTargetSize.shrinkWrap),
            child: Text(localizations(context).userSendMoney),
          ),
          ElevatedButton(
            onPressed: () => _kick(context),
            style: ElevatedButton.styleFrom(tapTargetSize: MaterialTapTargetSize.shrinkWrap),
            child: Text(localizations(context).userKick),
          ),
          ElevatedButton(
            onPressed: () => _transfer(context),
            style: ElevatedButton.styleFrom(tapTargetSize: MaterialTapTargetSize.shrinkWrap),
            child: Text(localizations(context).userTransfer),
          ),
        ]
      ],
    );
  }
}
