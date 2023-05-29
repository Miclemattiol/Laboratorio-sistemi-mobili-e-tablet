import 'package:flutter/material.dart';
import 'package:flutter_series/flutter_series.dart';
import 'package:house_wallet/data/user.dart';

class PartecipantsList extends StatelessWidget {
  final Set<User> partecipants;
  const PartecipantsList({
    required this.partecipants,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return PadColumn(children: [
      Text(
        'Partecipanti:', //TODO localization
        style: Theme.of(context).textTheme.titleMedium,
      ),
      ...partecipants.map((e) => Text(e.username)).toList()
    ]);
  }
}
