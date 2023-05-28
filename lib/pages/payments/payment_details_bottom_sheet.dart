import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_series/flutter_series.dart';
import 'package:house_wallet/components/form/date_picker_form_field.dart';
import 'package:house_wallet/components/form/number_form_field.dart';
import 'package:house_wallet/components/form/people_share_form_field.dart';
import 'package:house_wallet/components/ui/custom_bottom_sheet.dart';
import 'package:house_wallet/components/ui/image_avatar.dart';
import 'package:house_wallet/components/ui/modal_button.dart';
import 'package:house_wallet/data/firestore.dart';
import 'package:house_wallet/data/house_data.dart';
import 'package:house_wallet/data/logged_user.dart';
import 'package:house_wallet/data/payments/payment.dart';
import 'package:house_wallet/image_picker_bottom_sheet.dart';
import 'package:house_wallet/main.dart';
import 'package:house_wallet/pages/payments/payments_page.dart';
import 'package:house_wallet/themes.dart';

class PaymentDetailsBottomSheet extends StatefulWidget {
  final LoggedUser loggedUser;
  final HouseDataRef house;
  final FirestoreDocument<PaymentRef>? payment;

  const PaymentDetailsBottomSheet({
    required this.loggedUser,
    required this.house,
    super.key,
  }) : payment = null;

  const PaymentDetailsBottomSheet.edit(
    this.payment, {
    required this.loggedUser,
    required this.house,
    super.key,
  });

  @override
  State<PaymentDetailsBottomSheet> createState() => _PaymentDetailsBottomSheetState();
}

class _PaymentDetailsBottomSheetState extends State<PaymentDetailsBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  bool _loading = false;
  double? _uploadProgress;

  String? _titleValue;
  /* String? _categoryValue; */ //TODO category
  String? _descriptionValue;
  num? _priceValue;
  File? _imageValue;
  DateTime? _dateValue;

  Map<String, int>? _toValue;

  Future<void> _setImagePicture(DocumentReference doc) async {
    if (_imageValue == null) return;

    final upload = FirebaseStorage.instance.ref("groups/${widget.house.id}/${doc.id}.png").putFile(_imageValue!);

    setState(() => _uploadProgress = null);
    upload.snapshotEvents.listen((event) => setState(() => _uploadProgress = event.bytesTransferred / event.totalBytes));

    try {
      final imageUrl = await (await upload).ref.getDownloadURL();
      setState(() => _uploadProgress = null);

      await doc.update({
        "imageUrl": imageUrl
      });
    } on FirebaseException catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("${localizations(context).saveChangesDialogContentError}\n(${error.message})")));
    }
  }

  void _savePayment() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    _formKey.currentState!.save();
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    try {
      final payment = Payment(
        title: _titleValue!,
        category: "evPQw3qSnmIHEeZKeOGW",
        description: _descriptionValue,
        price: _priceValue!,
        imageUrl: null,
        date: _dateValue!,
        from: widget.loggedUser.uid,
        to: _toValue!,
      );

      DocumentReference ref = await () async {
        if (widget.payment == null) {
          return await PaymentsPage.paymentsFirestoreRef(widget.house.id).add(payment);
        } else {
          await widget.payment!.reference.update(Payment.toFirestore(payment));
          return widget.payment!.reference;
        }
      }();
      await _setImagePicture(ref);

      navigator.pop();
    } on FirebaseException catch (error) {
      scaffoldMessenger.showSnackBar(SnackBar(content: Text("${localizations(context).saveChangesDialogContentError}\n(${error.message})")));
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: CustomBottomSheet(
        dismissible: !_loading,
        spacing: 16,
        body: [
          PadRow(
            spacing: 16,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              ImageAvatar(
                _imageValue ?? widget.payment?.data.imageUrl,
                fallback: const Icon(Icons.image),
                progress: _uploadProgress,
                enabled: !_loading,
                onTap: () async {
                  final image = await ImagePickerBottomSheet.pickImage(context, image: _imageValue ?? widget.payment?.data.imageUrl);
                  if (image == null) return;
                  setState(() => _imageValue = image);
                },
              ),
              Expanded(
                child: TextFormField(
                  enabled: !_loading,
                  initialValue: widget.payment?.data.title,
                  decoration: inputDecoration(localizations(context).title, true),
                  onSaved: (title) => _titleValue = (title ?? "").trim().isEmpty ? null : title?.trim(),
                  validator: (value) => value?.trim().isEmpty == true ? localizations(context).titleInputErrorMissing : null,
                ),
              ),
              ConstrainedBox(
                constraints: multiInputRowConstraints(context),
                child: NumberFormField<double>(
                  enabled: !_loading,
                  initialValue: widget.payment?.data.price.toDouble(),
                  decoration: inputDecoration(localizations(context).price, true),
                  onSaved: (price) => _priceValue = price,
                  validator: (price) => (price == null || price <= 0) ? localizations(context).priceInvalid : null,
                ),
              ),
            ],
          ),
          PadRow(
            spacing: 16,
            children: [
              Expanded(
                child: PeopleSharesFormField(
                  enabled: !_loading,
                  house: widget.house,
                  initialValue: widget.payment?.data.to.map((key, value) => MapEntry(key, value.share)),
                  decoration: inputDecoration(localizations(context).peopleShares),
                  onSaved: (to) => _toValue = to,
                  validator: (value) {
                    if (value.entries.isEmpty) return localizations(context).noPeopleSharesInputErrorMissing;
                    return null;
                  },
                ),
              ),
              ConstrainedBox(
                constraints: multiInputRowConstraints(context),
                child: TextFormField(
                  enabled: !_loading,
                  decoration: inputDecoration("Category (TODO)"),
                ),
              ),
            ],
          ),
          DatePickerFormField(
            enabled: !_loading,
            initialValue: widget.payment?.data.date ?? DateTime.now(),
            decoration: inputDecoration(localizations(context).paymentDate),
            onSaved: (date) => _dateValue = date,
            validator: (value) {
              if (value == null) return localizations(context).paymentDateInputErrorMissing;
              if (value.isAfter(DateTime.now())) return localizations(context).paymentDateInputErrorFuture;
              return null;
            },
          ),
          TextFormField(
            enabled: !_loading,
            minLines: 1,
            maxLines: 5,
            initialValue: widget.payment?.data.description,
            decoration: inputDecoration(localizations(context).descriptionInput),
            keyboardType: TextInputType.multiline,
            onSaved: (description) => _descriptionValue = (description ?? "").trim().isEmpty ? null : description?.trim(),
          ),
        ],
        actions: [
          ModalButton(enabled: !_loading, onPressed: () => Navigator.of(context).pop(), child: Text(localizations(context).buttonCancel)),
          ModalButton(enabled: !_loading, onPressed: _savePayment, child: Text(localizations(context).buttonOk)),
        ],
      ),
    );
  }
}
