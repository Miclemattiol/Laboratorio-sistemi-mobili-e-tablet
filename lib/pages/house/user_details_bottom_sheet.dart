import 'package:flutter/material.dart';
import 'package:flutter_series/flutter_series.dart';
import 'package:house_wallet/components/ui/bottom_sheet_container.dart';
import 'package:house_wallet/components/user_avatar.dart';
import 'package:house_wallet/data/firestore.dart';
import 'package:house_wallet/data/logged_user.dart';
import 'package:house_wallet/data/user.dart';
import 'package:house_wallet/main.dart';

class UserDetailsBottomSheet extends StatelessWidget {
  final FirestoreDocument<User> user;

  const UserDetailsBottomSheet(
    this.user, {
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BottomSheetContainer(
      body: PadColumn(
        spacing: 8,
        padding: const EdgeInsets.all(16),
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PadRow(
            spacing: 16,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              UserAvatar(user.data.imageUrl),
              Text(user.data.username),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(localizations(context).userBalance(currencyFormat(context).format(10))), //TODO balance
          ),
          if (user.id == LoggedUser.uid) ...[
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(tapTargetSize: MaterialTapTargetSize.shrinkWrap),
              child: Text(localizations(context).userLeave),
            ),
          ] else ...[
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(tapTargetSize: MaterialTapTargetSize.shrinkWrap),
              child: Text(localizations(context).userSendMoney),
            ),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(tapTargetSize: MaterialTapTargetSize.shrinkWrap),
              child: Text(localizations(context).userKick),
            ),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(tapTargetSize: MaterialTapTargetSize.shrinkWrap),
              child: Text(localizations(context).userTransfer),
            ),
          ]
        ],
      ),
    );
  }
}
