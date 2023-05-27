import 'package:flutter/material.dart';
import 'package:flutter_series/flutter_series.dart';
import 'package:house_wallet/components/house/trade/trades_section.dart';
import 'package:house_wallet/components/house/user/users_section.dart';
import 'package:house_wallet/components/ui/app_bar_fix.dart';
import 'package:house_wallet/data/house/trade.dart';
import 'package:house_wallet/data/logged_user.dart';
import 'package:house_wallet/main.dart';

class HousePage extends StatelessWidget {
  const HousePage({super.key});

  @override
  Widget build(BuildContext context) {
    final loggedUser = LoggedUser.of(context);
    return StreamBuilder(
      stream: TradesSection.firestoreRef(loggedUser.houseId).where("accepted", isEqualTo: false).where("to", isEqualTo: loggedUser.uid).snapshots().map(TradeRef.converter(context)),
      builder: (context, snapshot) {
        return Scaffold(
          appBar: AppBarFix(title: Text(localizations(context).housePage)),
          body: SingleChildScrollView(
            child: PadColumn(
              spacing: 16,
              children: [
                if ((snapshot.connectionState != ConnectionState.waiting) && (snapshot.data?.isNotEmpty ?? true)) TradesSection(snapshot),
                const UsersSection(),
              ],
            ),
          ),
        );
      },
    );
  }
}
