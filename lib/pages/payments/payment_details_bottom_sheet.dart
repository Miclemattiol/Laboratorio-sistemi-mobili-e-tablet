import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_series/flutter_series.dart';
import 'package:house_wallet/components/form/date_picker_form_field.dart';
import 'package:house_wallet/components/form/number_form_field.dart';
import 'package:house_wallet/components/ui/custom_bottom_sheet.dart';
import 'package:house_wallet/components/ui/modal_button.dart';
import 'package:house_wallet/components/ui/user_avatar.dart';
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
  double? _uploadProgress;
  bool _edited = false;

  File? _imageFile;
  String? _titleValue;
  String? _descriptionValue;
  num? _priceValue;
  DateTime? _transactonDateValue;

  void _chooseImage() async {
    final image = await ImagePickerBottomSheet.pickImage(context, imageUrl: widget.payment?.data.imageUrl);
    if (image == null) return;

    setState(() {
      _imageFile = image;
      _uploadProgress = 0;
    });
  }

  Future<void> _setImagePicture(DocumentReference doc) async {
    if (_imageFile == null) return;

    final upload = FirebaseStorage.instance.ref("groups/${widget.house.id}/${doc.id}.png").putFile(_imageFile!);

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

    try {
      final payment = Payment(
        title: _titleValue!,
        category: "evPQw3qSnmIHEeZKeOGW", //TODO category
        description: _descriptionValue ?? "",
        price: _priceValue!,
        imageUrl: "",
        date: _transactonDateValue!,
        from: widget.loggedUser.uid,
        to: {
          widget.loggedUser.uid: 1
        },
      );

      DocumentReference ref;
      if (widget.payment == null) {
        ref = await PaymentsPage.paymentsFirestoreRef(widget.house.id).add(payment);
      } else {
        await widget.payment!.reference.update(Payment.toFirestore(payment));
        ref = widget.payment!.reference;
      }
      await _setImagePicture(ref);

      navigator.pop();
    } on FirebaseException catch (error) {
      scaffoldMessenger.showSnackBar(SnackBar(content: Text("${localizations(context).saveChangesDialogContentError}\n(${error.message})")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: CustomBottomSheet(
        spacing: 16,
        body: [
          PadRow(
            spacing: 16,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              SizedBox(
                width: 64,
                height: 64,
                child: Stack(
                  children: [
                    GestureDetector(
                      onTap: _chooseImage,
                      child: _imageFile != null ? ImageAvatar.file(_imageFile!, fallback: const Icon(Icons.image)) : ImageAvatar(widget.payment?.data.imageUrl, fallback: const Icon(Icons.image)),
                    ),
                    if (_uploadProgress != null)
                      Container(
                        width: 64,
                        height: 64,
                        clipBehavior: Clip.antiAlias,
                        decoration: ImageAvatar.border(context).copyWith(color: Colors.black26),
                        child: Padding(
                          padding: const EdgeInsets.all(48),
                          child: CircularProgressIndicator(value: _uploadProgress),
                        ),
                      )
                  ],
                ),
              ),
              Expanded(
                child: TextFormField(
                  initialValue: widget.payment?.data.title ?? "",
                  decoration: inputDecoration(localizations(context).title, true),
                  onChanged: (title) {
                    if (!_edited && title.trim().isNotEmpty) _edited = true;
                  },
                  onSaved: (title) => _titleValue = (title ?? "").trim().isEmpty ? null : title?.trim(),
                  validator: (value) => value?.trim().isEmpty == true ? localizations(context).paymentTitleInvalid : null,
                ),
              ),
              ConstrainedBox(
                constraints: multiInputRowConstraints(context),
                child: NumberFormField<num>(
                  initialValue: widget.payment?.data.price,
                  decoration: inputDecoration(localizations(context).price, true),
                  onChanged: (price) {
                    if (!_edited && price != null) _edited = true;
                  },
                  onSaved: (price) => _priceValue = price,
                  validator: (price) => (price == null || price <= 0) ? localizations(context).priceInvalid : null,
                ),
              ),
            ],
          ),
          TextFormField(
            //TODO select category
            decoration: inputDecoration("TODO"),
          ),
          DatePickerFormField(
            initialValue: widget.payment?.data.date ?? DateTime.now(),
            decoration: inputDecoration(localizations(context).paymentDate),
            onChanged: (date) {
              if (!_edited) _edited = true;
            },
            onSaved: (date) => _transactonDateValue = date,
          ),
          TextFormField(
            initialValue: widget.payment?.data.description ?? "",
            decoration: inputDecoration(localizations(context).descriptionInput),
            keyboardType: TextInputType.multiline,
            minLines: 1,
            maxLines: 5,
            onChanged: (description) {
              if (!_edited && description.trim().isNotEmpty) _edited = true;
            },
            onSaved: (description) => _descriptionValue = (description ?? "").trim().isEmpty ? null : description?.trim(),
          ),
        ],
        actions: [
          ModalButton(onPressed: () => Navigator.of(context).pop(), child: Text(localizations(context).buttonCancel)),
          ModalButton(onPressed: _savePayment, child: Text(localizations(context).buttonOk)),
        ],
      ),
    );
  }
}
