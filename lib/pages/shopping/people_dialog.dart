import 'package:flutter/material.dart';
import 'package:flutter_series/flutter_series.dart';
import 'package:house_wallet/components/ui/custom_dialog.dart';
import 'package:house_wallet/components/ui/modal_button.dart';
import 'package:house_wallet/data/house_data.dart';
import 'package:house_wallet/main.dart';

class PeopleDialog extends StatefulWidget {
  final HouseDataRef house;
  final Set<String>? initialValue;

  const PeopleDialog({
    required this.house,
    this.initialValue,
    super.key,
  });

  @override
  State<PeopleDialog> createState() => _PeopleDialogState();
}

class _PeopleDialogState extends State<PeopleDialog> {
  late final users = widget.house.users.values.where((user) => user.uid.isNotEmpty);
  late final Set<String> _value = Set.from(widget.initialValue ?? {});

  @override
  Widget build(BuildContext context) {
    return CustomDialog(
      dismissible: false,
      padding: const EdgeInsets.all(24),
      crossAxisAlignment: CrossAxisAlignment.center,
      body: users.map((user) {
        return PadRow(
          spacing: 8,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Checkbox(
              value: _value.contains(user.uid),
              onChanged: (value) => setState(() => value! ? _value.add(user.uid) : _value.remove(user.uid)),
              visualDensity: VisualDensity.compact,
            ),
            Expanded(child: Text(user.username, overflow: TextOverflow.ellipsis, softWrap: false)),
          ],
        );
      }).toList(),
      actions: [
        ModalButton(onPressed: () => Navigator.of(context).pop<Set<String>?>(), child: Text(localizations(context).buttonCancel)),
        ModalButton(onPressed: () => Navigator.of(context).pop<Set<String>?>(_value), child: Text(localizations(context).buttonOk)),
      ],
    );
  }
}
