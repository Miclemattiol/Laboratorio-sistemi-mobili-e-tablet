import 'package:flutter/material.dart';
import 'package:flutter_series/flutter_series.dart';
import 'package:house_wallet/components/form/number_form_field.dart';
import 'package:house_wallet/components/ui/custom_dialog.dart';
import 'package:house_wallet/components/ui/modal_button.dart';
import 'package:house_wallet/data/house_data.dart';
import 'package:house_wallet/main.dart';
import 'package:house_wallet/themes.dart';

class PeopleSharesDialog extends StatefulWidget {
  final HouseDataRef house;
  final Map<String, int>? initialValues;

  const PeopleSharesDialog({
    required this.house,
    this.initialValues,
    super.key,
  });

  @override
  State<PeopleSharesDialog> createState() => _PeopleSharesDialogState();
}

class _UserShare {
  int value;
  bool enabled;

  _UserShare(this.value, this.enabled);
}

class _PeopleSharesDialogState extends State<PeopleSharesDialog> {
  late final users = widget.house.users.values.where((user) => user.uid.isNotEmpty);
  late final initialValues = widget.initialValues ?? {};
  late final Map<String, _UserShare> _values = Map.fromEntries(users.map((user) => MapEntry(user.uid, _UserShare(initialValues[user.uid] ?? 1, initialValues.containsKey(user.uid)))));

  void _submit() {
    final Map<String, int> values = Map.fromEntries(_values.entries.where((entry) => entry.value.enabled && entry.value.value != 0).map((entry) => MapEntry(entry.key, entry.value.value)));
    Navigator.of(context).pop<Map<String, int>?>(values);
  }

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
              value: _values[user.uid]!.enabled,
              onChanged: (value) => setState(() => _values[user.uid]!.enabled = value!),
              visualDensity: VisualDensity.compact,
            ),
            Expanded(child: Text(user.username, overflow: TextOverflow.ellipsis, softWrap: false)),
            SizedBox(
              width: 48,
              child: NumberFormField<int>(
                initialValue: _values[user.uid]!.value,
                enabled: _values[user.uid]!.enabled,
                textAlign: TextAlign.center,
                decoration: inputDecoration().copyWith(contentPadding: EdgeInsets.zero),
                onChanged: (value) => setState(() {
                  if (value != null) {
                    _values[user.uid]!.value = value;
                  }
                }),
              ),
            )
          ],
        );
      }).toList(),
      actions: [
        ModalButton(onPressed: () => Navigator.of(context).pop<Map<String, int>?>(), child: Text(localizations(context).cancel)),
        ModalButton(onPressed: _submit, child: Text(localizations(context).ok)),
      ],
    );
  }
}
