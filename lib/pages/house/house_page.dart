import 'package:flutter/material.dart';
import 'package:flutter_series/flutter_series.dart';
import 'package:house_wallet/components/house/trades_section.dart';
import 'package:house_wallet/components/house/users_section.dart';
import 'package:house_wallet/components/sliding_page_route.dart';
import 'package:house_wallet/components/ui/app_bar_fix.dart';
import 'package:house_wallet/components/ui/link_list_tile.dart';
import 'package:house_wallet/main.dart';
import 'package:house_wallet/pages/house/activity_log_page.dart';

class HousePage extends StatelessWidget {
  const HousePage({super.key});

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
            const TradesSection(),
            const UsersSection(),
          ],
        ),
      ),
    );
  }
}
