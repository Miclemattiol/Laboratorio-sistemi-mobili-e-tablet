import 'package:flutter/material.dart';
import 'package:flutter_series/flutter_series.dart';
import 'package:house_wallet/data/user.dart';
import 'package:house_wallet/main.dart';

class ParticipantsList extends StatelessWidget {
  final Set<User> participants;

  const ParticipantsList(
    this.participants, {
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return PadColumn(children: [
      Text(
        localizations(context).taskAssignedToInput,
        style: Theme.of(context).textTheme.titleMedium,
      ),
      ...participants.map((e) => Text(e.username)).toList()
    ]);
  }
}
