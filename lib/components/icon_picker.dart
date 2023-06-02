import 'package:flutter/material.dart';
import 'package:house_wallet/components/ui/custom_dialog.dart';
import 'package:house_wallet/components/ui/modal_button.dart';
import 'package:house_wallet/data/icons.dart';
import 'package:house_wallet/main.dart';

class IconPicker extends StatefulWidget {
  const IconPicker._();

  static Future<IconData?> pickIcon(BuildContext context) {
    return showDialog<IconData>(context: context, builder: (context) => const IconPicker._());
  }

  @override
  State<IconPicker> createState() => _IconPickerState();
}

class _IconPickerState extends State<IconPicker> {
  String _filter = "";

  @override
  Widget build(BuildContext context) {
    return CustomDialog(
      dismissible: false,
      padding: const EdgeInsets.all(16),
      crossAxisAlignment: CrossAxisAlignment.center,
      spacing: 16,
      body: [
        TextField(
          autofocus: true,
          onChanged: (filter) => setState(() => _filter = filter.toLowerCase()),
          decoration: InputDecoration(
            border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(100))),
            contentPadding: EdgeInsets.zero,
            isDense: true,
            prefixIcon: const Icon(Icons.search),
            hintText: localizations(context).iconPickerSearch,
          ),
        ),
        SizedBox(
          height: MediaQuery.of(context).size.height / 3,
          child: () {
            final filteredIcons = icons.entries.where((icon) => icon.key.contains(_filter));

            if (filteredIcons.isEmpty) {
              return Center(
                child: Text(
                  localizations(context).filterError(_filter),
                  textAlign: TextAlign.center,
                ),
              );
            }

            return SingleChildScrollView(
              child: Wrap(
                spacing: 12,
                runSpacing: 12,
                children: filteredIcons.map((icon) {
                  return GestureDetector(
                    onTap: () => Navigator.of(context).pop<IconData>(icon.value),
                    child: Tooltip(
                      message: icon.key,
                      child: Icon(icon.value, size: 24),
                    ),
                  );
                }).toList(),
              ),
            );
          }(),
        )
      ],
      actions: [
        ModalButton(onPressed: () => Navigator.of(context).pop<IconData?>(), child: Text(localizations(context).cancel)),
      ],
    );
  }
}
