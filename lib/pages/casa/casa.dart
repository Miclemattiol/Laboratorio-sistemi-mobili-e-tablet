import 'package:flutter/material.dart';
import 'package:flutter_series/flutter_series.dart';
import 'package:house_wallet/components/casa/section.dart';
import 'package:house_wallet/components/sliding_page_route.dart';
import 'package:house_wallet/components/ui/app_bar_fix.dart';
import 'package:house_wallet/components/ui/link_list_tile.dart';
import 'package:house_wallet/pages/casa/registro_attivita.dart';

class Casa extends StatelessWidget {
  const Casa({super.key});

  static const label = "Casa";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarFix(title: const Text(label)),
      body: SingleChildScrollView(
        child: PadColumn(
          spacing: 16,
          children: [
            LinkListTile(
              title: "Registro attività",
              onTap: () => Navigator.of(context).push(SlidingPageRoute(const RegistroAttivita())),
            ),
            const Section(
              title: "Scambi",
              children: [
                ListTile(title: Text("Scambio 1")),
                ListTile(title: Text("Scambio 2")),
                ListTile(title: Text("Scambio 3")),
              ],
            ),
            const Section(
              title: "Utenti",
              children: [
                ListTile(title: Text("Utente 1")),
                ListTile(title: Text("Utente 2")),
                ListTile(title: Text("Utente 3")),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
