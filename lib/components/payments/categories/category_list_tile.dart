import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_series/flutter_series.dart';
import 'package:house_wallet/components/ui/custom_dialog.dart';
import 'package:house_wallet/data/firestore.dart';
import 'package:house_wallet/data/house_data.dart';
import 'package:house_wallet/data/payments/category.dart';
import 'package:house_wallet/main.dart';
import 'package:house_wallet/pages/payments/categories/category_dialog.dart';
import 'package:house_wallet/utils.dart';

class CategoryListTile extends StatelessWidget {
  final FirestoreDocument<Category> category;
  final HouseDataRef house;

  CategoryListTile(
    this.category, {
    required this.house,
  }) : super(key: Key(category.id));

  static Widget shimmer({required double titleWidth}) {
    return PadRow(
      crossAxisAlignment: CrossAxisAlignment.center,
      padding: const EdgeInsets.symmetric(vertical: 21, horizontal: 16),
      children: [
        Container(width: 24, height: 24, color: Colors.white),
        Padding(padding: const EdgeInsets.symmetric(horizontal: 13), child: Container(height: 14, width: titleWidth, color: Colors.white)),
      ],
    );
  }

  void _delete(BuildContext context) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final appLocalizations = localizations(context);

    if (await isNotConnectedToInternet(context) || !context.mounted) return;

    if (await CustomDialog.confirm(context: context, title: localizations(context).delete, content: localizations(context).deleteCategoryConfirm(category.data.name))) {
      try {
        await category.reference.delete();
      } on FirebaseException catch (error) {
        scaffoldMessenger.showSnackBar(SnackBar(content: Text(appLocalizations.actionError(error.message.toString()))));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.only(left: 16, right: 16),
      leading: SizedBox(height: double.infinity, child: Icon(category.data.icon)),
      trailing: GestureDetector(
        onTap: () => _delete(context),
        child: const Icon(Icons.delete),
      ),
      title: Text(category.data.name),
      onTap: () => showDialog(context: context, builder: (context) => CategoryDialog.edit(category, house: house)),
    );
  }
}
