import 'package:flutter/material.dart';
import 'package:flutter_series/flutter_series.dart';
import 'package:house_wallet/components/house/trade/trades_section.dart';
import 'package:house_wallet/components/house/user/users_section.dart';
import 'package:house_wallet/components/ui/app_bar_fix.dart';
import 'package:house_wallet/data/house/trade.dart';
import 'package:house_wallet/data/logged_user.dart';
import 'package:house_wallet/data/user.dart';
import 'package:house_wallet/main.dart';
import 'package:multiple_stream_builder/multiple_stream_builder.dart';

class HousePage extends StatelessWidget {
  const HousePage({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder2(
      streams: StreamTuple2(
        TradesSection.firestoreRef.where("accepted", isEqualTo: false).where("to", isEqualTo: LoggedUser.uid).snapshots().asyncMap(TradeRef.converter),
        UsersSection.firestoreRef.snapshots().asyncMap(User.converter),
      ),
      builder: (context, streams) {
        final trades = streams.snapshot1;
        final users = streams.snapshot2;
        return Scaffold(
          appBar: AppBarFix(title: Text(localizations(context).housePage)),
          body: SingleChildScrollView(
            child: PadColumn(
              spacing: 16,
              children: [
                if ((trades.connectionState != ConnectionState.waiting) && (trades.data?.isNotEmpty ?? true)) TradesSection(trades),
                UsersSection(users),
              ],
            ),
          ),
        );
      },
    );
  }
}
