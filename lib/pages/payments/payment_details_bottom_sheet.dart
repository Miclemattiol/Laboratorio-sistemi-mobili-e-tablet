import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_series/flutter_series.dart';
import 'package:house_wallet/components/form/category_form_field.dart';
import 'package:house_wallet/components/form/date_picker_form_field.dart';
import 'package:house_wallet/components/form/number_form_field.dart';
import 'package:house_wallet/components/form/people_share_form_field.dart';
import 'package:house_wallet/components/image_picker_bottom_sheet.dart';
import 'package:house_wallet/components/ui/custom_bottom_sheet.dart';
import 'package:house_wallet/components/ui/custom_dialog.dart';
import 'package:house_wallet/components/ui/image_avatar.dart';
import 'package:house_wallet/components/ui/modal_button.dart';
import 'package:house_wallet/data/firestore.dart';
import 'package:house_wallet/data/house_data.dart';
import 'package:house_wallet/data/logged_user.dart';
import 'package:house_wallet/data/payments/category.dart';
import 'package:house_wallet/data/payments/payment.dart';
import 'package:house_wallet/main.dart';
import 'package:house_wallet/pages/payments/categories/category_dialog.dart';
import 'package:house_wallet/pages/payments/payments_page.dart';
import 'package:house_wallet/themes.dart';
import 'package:house_wallet/utils.dart';
import 'package:uuid/uuid.dart';

class PaymentDetailsBottomSheet extends StatefulWidget {
  final LoggedUser loggedUser;
  final HouseDataRef house;
  final List<FirestoreDocument<Category>> categories;
  final FirestoreDocument<PaymentRef>? payment;

  const PaymentDetailsBottomSheet({
    required this.loggedUser,
    required this.house,
    required this.categories,
    super.key,
  }) : payment = null;

  const PaymentDetailsBottomSheet.edit(
    FirestoreDocument<PaymentRef> this.payment, {
    required this.loggedUser,
    required this.house,
    required this.categories,
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
  String? _categoryValue;
  String? _descriptionValue;
  num? _priceValue;
  File? _imageValue;
  DateTime? _dateValue;
  Map<String, int> _toValue = {};

  Future<String> _uploadImage(File image) async {
    final upload = FirebaseStorage.instance.ref("groups/${widget.house.id}/payments/${const Uuid().v1()}.png").putFile(image);

    setState(() => _uploadProgress = null);
    upload.snapshotEvents.listen((event) => setState(() => _uploadProgress = event.bytesTransferred / event.totalBytes));

    final imageRef = (await upload).ref;
    setState(() => _uploadProgress = null);
    return imageRef.getDownloadURL();
  }

  void _savePayment() async {
    final navigator = Navigator.of(context);

    _formKey.currentState!.save();
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    try {
      if (_categoryValue == CategoryFormField.newCategoryKey) {
        _categoryValue = await showDialog<String?>(context: context, builder: (context) => CategoryDialog(house: widget.house));
        if (_categoryValue == null) {
          setState(() => _loading = false);
          return;
        }
      }

      if (widget.payment == null) {
        await FirebaseFirestore.instance.runTransaction((transaction) async {
          transaction.set<Payment>(
            PaymentsPage.paymentsFirestoreRef(widget.house.id).doc(),
            Payment(
              title: _titleValue!,
              category: _categoryValue,
              description: _descriptionValue,
              price: _priceValue!,
              imageUrl: _imageValue == null ? null : await _uploadImage(_imageValue!),
              date: _dateValue!,
              from: widget.loggedUser.uid,
              to: _toValue,
            ),
          );

          widget.house.updateBalances(
            transaction,
            newValues: SharesData(from: widget.loggedUser.uid, price: _priceValue!, shares: _toValue),
          );
        });
      } else {
        final payment = widget.payment!.data;
        await FirebaseFirestore.instance.runTransaction((transaction) async {
          transaction.update(
            widget.payment!.reference,
            {
              Payment.titleKey: _titleValue!,
              Payment.categoryKey: _categoryValue,
              Payment.descriptionKey: _descriptionValue,
              Payment.priceKey: _priceValue!,
              Payment.imageUrlKey: _imageValue == null ? payment.imageUrl : await _uploadImage(_imageValue!),
              Payment.dateKey: _dateValue!,
              Payment.toKey: _toValue,
            },
          );

          widget.house.updateBalances(
            transaction,
            prevValues: SharesData(from: payment.from.uid, price: payment.price, shares: payment.shares),
            newValues: SharesData(from: payment.from.uid, price: _priceValue!, shares: _toValue),
          );
        });

        if (_imageValue != null && payment.imageUrl != null) {
          try {
            await FirebaseStorage.instance.refFromURL(payment.imageUrl!).delete();
          } catch (_) {}
        }
      }

      navigator.pop();
    } on FirebaseException catch (error) {
      if (!context.mounted) return;
      CustomDialog.alert(
        context: context,
        title: localizations(context).error,
        content: error.code == HouseDataRef.invalidUsersError ? localizations(context).balanceInvalidUser : localizations(context).saveChangesError(error.message.toString()),
      );
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
                  onSaved: (title) => _titleValue = title.toNullable(),
                  validator: (value) => value?.trim().isEmpty == true ? localizations(context).titleMissing : null,
                ),
              ),
              ConstrainedBox(
                constraints: multiInputRowConstraints(context),
                child: NumberFormField<double>(
                  enabled: !_loading,
                  initialValue: widget.payment?.data.price.toDouble(),
                  decoration: inputDecoration(localizations(context).price, true),
                  onSaved: (price) => _priceValue = price,
                  validator: (price) => (price == null) ? localizations(context).priceMissing : null,
                ),
              ),
            ],
          ),
          PeopleSharesFormField(
            enabled: !_loading,
            house: widget.house,
            initialValue: widget.payment?.data.to.map((key, value) => MapEntry(key, value.share)) ?? widget.house.users.map((key, value) => MapEntry(key, 1)),
            decoration: inputDecoration(localizations(context).peopleShares),
            onSaved: (to) => _toValue = to,
            validator: (value) => (value.entries.isEmpty) ? localizations(context).peopleSharesMissing : null,
          ),
          CategoryFormField(
            categories: widget.categories,
            enabled: !_loading,
            initialValue: widget.payment?.data.category,
            decoration: inputDecoration(localizations(context).category),
            onSaved: (category) => _categoryValue = category,
          ),
          DatePickerFormField(
            enabled: !_loading,
            initialValue: widget.payment?.data.date ?? DateTime.now(),
            lastDate: DateTime.now(),
            decoration: inputDecoration(localizations(context).date),
            onSaved: (date) => _dateValue = date,
            validator: (value) => (value == null) ? localizations(context).dateMissing : null,
          ),
          TextFormField(
            enabled: !_loading,
            minLines: 1,
            maxLines: 5,
            initialValue: widget.payment?.data.description,
            decoration: inputDecoration(localizations(context).description),
            keyboardType: TextInputType.multiline,
            onSaved: (description) => _descriptionValue = description.toNullable(),
          ),
        ],
        actions: [
          ModalButton(enabled: !_loading, onPressed: () => Navigator.of(context).pop(), child: Text(localizations(context).cancel)),
          ModalButton(enabled: !_loading, onPressed: _savePayment, child: Text(localizations(context).ok)),
        ],
      ),
    );
  }
}
