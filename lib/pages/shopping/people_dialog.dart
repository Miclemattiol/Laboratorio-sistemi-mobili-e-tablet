import 'package:flutter/material.dart';
import 'package:house_wallet/components/ui/custom_dialog.dart';
import 'package:house_wallet/components/ui/modal_button.dart';
import 'package:house_wallet/main.dart';
import 'package:house_wallet/themes.dart';

class PeopleDialog extends StatefulWidget {
  final Map<String, int>? initialValue;

  const PeopleDialog({
    required this.initialValue,
    super.key,
  });

  @override
  State<PeopleDialog> createState() => _PeopleDialogState();
}

class _PeopleDialogState extends State<PeopleDialog> {
  GlobalKey<FormState> formKey = GlobalKey();

  String? supermarketValue;

  @override
  Widget build(BuildContext context) {
    void submit() {
      formKey.currentState!.save();
      Navigator.of(context).pop<String?>(supermarketValue);
    }

    return Form(
      key: formKey,
      child: FutureBuilder(
          future: Future.delayed(const Duration(seconds: 1)),
          builder: (context, snapshot) {
            //TODO
            if (true || snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            return CustomDialog(
              dismissible: false,
              padding: const EdgeInsets.all(24),
              crossAxisAlignment: CrossAxisAlignment.center,
              body: [
                TextFormField(
                  autofocus: true,
                  decoration: inputDecoration(localizations(context).supermarketChipTooltip),
                  onSaved: (newValue) => supermarketValue = (newValue ?? "").trim().isEmpty ? null : newValue?.trim(),
                ),
              ],
              actions: [
                ModalButton(onPressed: () => Navigator.of(context).pop<String?>(), child: Text(localizations(context).buttonCancel)),
                ModalButton(onPressed: submit, child: Text(localizations(context).buttonOk)),
              ],
            );
          }),
    );
  }
}
