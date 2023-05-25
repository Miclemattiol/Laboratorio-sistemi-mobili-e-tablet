import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_series/flutter_series.dart';
import 'package:house_wallet/components/ui/custom_bottom_sheet.dart';
import 'package:house_wallet/components/ui/modal_button.dart';
import 'package:house_wallet/components/ui/payment_image.dart';
import 'package:house_wallet/data/firestore.dart';
import 'package:house_wallet/data/logged_user.dart';
import 'package:house_wallet/data/payments/payment.dart';
import 'package:house_wallet/image_picker.dart';
import 'package:house_wallet/main.dart';
import 'package:house_wallet/pages/payments/payments_page.dart';
import 'package:house_wallet/themes.dart';

class PaymentDetailsBottomSheet extends StatefulWidget {
  final FirestoreDocument<PaymentRef>? _payment;

  const PaymentDetailsBottomSheet({super.key}) : _payment = null;
  const PaymentDetailsBottomSheet.edit(this._payment, {super.key});

  @override
  State<PaymentDetailsBottomSheet> createState() => _PaymentDetailsBottomSheetState();
}

class _PaymentDetailsBottomSheetState extends State<PaymentDetailsBottomSheet> {
  double? _uploadProgress;
  File? _imageFile;
  bool _edited = false;
  final _formKey = GlobalKey<FormState>();
  String? _title;
  String? _description;
  double? _price;

  _setImagePicture(DocumentReference p) async {
    if (_imageFile == null) return;

    final upload = FirebaseStorage.instance.ref("groups/${LoggedUser.houseId}/${p.id}.png").putFile(_imageFile!);

    setState(() => _uploadProgress = null);
    upload.snapshotEvents.listen((event) => setState(() => _uploadProgress = event.bytesTransferred / event.totalBytes));

    try {
      final imageUrl = await (await upload).ref.getDownloadURL();
      setState(() => _uploadProgress = null);

      await p.update({
        "imageUrl": imageUrl
      });
    } on FirebaseException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("${localizations(context).saveChangesDialogContentError}\n(${e.message})")));
    }
  }

  _savePayment() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    try {
      final payment = Payment(
        title: _title!,
        category: "evPQw3qSnmIHEeZKeOGW",
        description: _description ?? "",
        price: _price!,
        imageUrl: "",
        date: DateTime.now(),
        from: LoggedUser.uid!,
        to: {
          LoggedUser.uid!: 1
        },
      );

      DocumentReference ref;

      if (widget._payment == null) {
        ref = await PaymentsPage.paymentsFirestoreRef.add(payment);
      } else {
        widget._payment!.reference.update(Payment.toFirestore(payment));
        ref = widget._payment!.reference;
      }

      await _setImagePicture(ref);

      navigator.pop();
    } on FirebaseException catch (e) {
      scaffoldMessenger.showSnackBar(SnackBar(content: Text("${localizations(context).saveChangesDialogContentError}\n(${e.message})")));
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
                        onTap: () async => () async {
                              final image = await pickImage(context); //TODO fix image picker add String? imageURL to visualize image
                              if (image == null) return;
                              setState(() {
                                _imageFile = image;
                                _uploadProgress = 0;
                              });
                            }(),
                        child: _imageFile != null ? PaymentImage.file(_imageFile, size: 64) : PaymentImage(widget._payment != null ? widget._payment!.data.imageUrl : "", size: 64)),
                    if (_uploadProgress != null)
                      Container(
                        width: 64,
                        height: 64,
                        clipBehavior: Clip.antiAlias,
                        decoration: PaymentImage.border(context).copyWith(color: Colors.black26),
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
                  initialValue: widget._payment?.data.title ?? "",
                  decoration: inputDecoration(localizations(context).title).copyWith(errorStyle: const TextStyle(fontSize: 10)),
                  onChanged: (title) {
                    if (!_edited && title.trim().isNotEmpty) _edited = true;
                  },
                  onSaved: (title) => _title = (title ?? "").trim().isEmpty ? null : title?.trim(),
                  validator: (value) => value?.trim().isEmpty == true ? localizations(context).paymentTitleInvalid : null,
                ),
              ),
              SizedBox(
                width: 120,
                child: TextFormField(
                  initialValue: widget._payment?.data.price.toStringAsFixed(2) ?? "",
                  decoration: inputDecoration(localizations(context).price).copyWith(errorStyle: const TextStyle(fontSize: 10)),
                  keyboardType: TextInputType.number,
                  onChanged: (price) {
                    if (!_edited && price.trim().isNotEmpty) _edited = true;
                  },
                  onSaved: (price) => _price = (price ?? "").trim().isEmpty ? null : double.parse(price!),
                  validator: (value) {
                    try {
                      final price = double.parse(value!);
                      if (price <= 0) return localizations(context).priceInvalid;
                      return null;
                    } catch (e) {
                      return localizations(context).priceInvalid;
                    }
                  },
                ),
              ),
            ],
          ),
          TextFormField(
            decoration: inputDecoration("TODO"),
          ),
          TextFormField(
            decoration: inputDecoration("TODO"),
          ),
          TextFormField(
            initialValue: widget._payment?.data.description ?? "",
            decoration: inputDecoration(localizations(context).descriptionInput),
            keyboardType: TextInputType.multiline,
            minLines: 1,
            maxLines: 5,
            onChanged: (description) {
              if (!_edited && description.trim().isNotEmpty) _edited = true;
            },
            onSaved: (description) => _description = (description ?? "").trim().isEmpty ? null : description?.trim(),
          ),
        ],
        actions: [
          ModalButton(onPressed: () => Navigator.of(context).pop(), child: Text(localizations(context).buttonCancel)),
          ModalButton(
              onPressed: () {
                _savePayment();
              },
              child: Text(localizations(context).buttonOk)),
        ],
      ),
    );
  }
}
