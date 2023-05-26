import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_series/flutter_series.dart';
import 'package:house_wallet/components/ui/custom_bottom_sheet.dart';
import 'package:house_wallet/components/ui/modal_button.dart';
import 'package:house_wallet/components/ui/user_avatar.dart';
import 'package:house_wallet/data/firestore.dart';
import 'package:house_wallet/data/logged_user.dart';
import 'package:house_wallet/data/payments/payment.dart';
import 'package:house_wallet/image_picker.dart';
import 'package:house_wallet/main.dart';
import 'package:house_wallet/pages/payments/payments_page.dart';
import 'package:house_wallet/themes.dart';
import 'package:intl/intl.dart';

class TaskDetailsBottomSheet extends StatefulWidget {
  const TaskDetailsBottomSheet({super.key});

  const TaskDetailsBottomSheet.edit({super.key});

  @override
  State<TaskDetailsBottomSheet> createState() => _TaskDetailsBottomSheetState();
}

class _TaskDetailsBottomSheetState extends State<TaskDetailsBottomSheet> {
  final _formKey = GlobalKey<FormState>();

  String? _descriptionValue;
  bool _edited = false;

  TextEditingController fromDateController = TextEditingController();

  _saveTask() async {
    if (!_edited) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: CustomBottomSheet(
        spacing: 16,
        body: [
          TextFormField(
            decoration: inputDecoration("Title"),
          ),
          PadRow(
            crossAxisAlignment: CrossAxisAlignment.center,
            spacing: 8,
            children: [
              const Text("Data inizio:", style: TextStyle(fontSize: 16)),
              Expanded(
                child: TextFormField(
                  decoration: inputDecoration("Data inizio:"),
                  controller: fromDateController,
                  readOnly: true,
                  onTap: () async {
                    final date = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime(2000), lastDate: DateTime(2101));
                    if (date == null) return;
                    String formattedDate = DateFormat('dd/MM/yyyy').format(date);
                    fromDateController.text = formattedDate;
                    setState(() {
                      fromDateController.text = formattedDate;
                      _edited = true;
                    });
                  },
                ),
              ),
            ],
          ),
        ],
        actions: [
          ModalButton(onPressed: () => Navigator.of(context).pop(), child: Text(localizations(context).buttonCancel)),
          ModalButton(onPressed: _saveTask, child: Text(localizations(context).buttonOk)),
        ],
      ),
    );
  }
}
