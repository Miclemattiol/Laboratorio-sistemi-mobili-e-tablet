import 'package:flutter/material.dart';
import 'package:flutter_series/flutter_series.dart';
import 'package:house_wallet/components/house/section.dart';
import 'package:house_wallet/components/house/trade_list_tile.dart';
import 'package:house_wallet/components/house/user_list_tile.dart';
import 'package:house_wallet/components/sliding_page_route.dart';
import 'package:house_wallet/components/ui/app_bar_fix.dart';
import 'package:house_wallet/components/ui/link_list_tile.dart';
import 'package:house_wallet/data/house/trade.dart';
import 'package:house_wallet/data/logged_user.dart';
import 'package:house_wallet/data/user.dart';
import 'package:house_wallet/main.dart';
import 'package:house_wallet/pages/house/activity_log_page.dart';

const trades = <Trade>[
  Trade(amount: 20, from: "Mario Rossi"),
  Trade(amount: 500, from: "Brutto Signore"),
];

class HousePage extends StatelessWidget {
  const HousePage({super.key});

  List<User> get users {
    return [
      User(id: LoggedUser.uid!, name: "Mario Rossi", balance: 43),
      const User(id: "a", name: "Luigi Verdi", balance: 123),
      const User(id: "b", name: "Paolo Bianchi", balance: 4),
      const User(id: "c", name: "Bruno Gialli", balance: 2),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarFix(title: Text(localizations(context).housePage)),
      body: SingleChildScrollView(
        child: PadColumn(
          spacing: 16,
          children: [
            LinkListTile(
              title: localizations(context).activityLogPage,
              onTap: () => Navigator.of(context).push(SlidingPageRoute(const ActivityLogPage())),
            ),
            Section(
              title: localizations(context).tradesSection,
              children: trades.map((trade) {
                return TradeListTile(
                  trade,
                  onAccept: () {},
                  onDeny: () {},
                );
              }).toList(),
            ),
            Section(
              title: localizations(context).usersSection,
              children: [
                ...users.map(UserListTile.new),
                const UserListTile.invite()
              ],
            ),
          ],
        ),
      ),
    );
  }
}
