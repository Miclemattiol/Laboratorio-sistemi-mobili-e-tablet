import 'package:flutter/material.dart';
import 'package:flutter_series/flutter_series.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:house_wallet/data/firestore.dart';
import 'package:house_wallet/data/house_data.dart';
import 'package:house_wallet/data/payments/category.dart';
import 'package:house_wallet/pages/payments/categories/category_dialog.dart';

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

  @override
  Widget build(BuildContext context) {
    return Slidable(
      key: Key(category.id),
      endActionPane: ActionPane(
        extentRatio: .2,
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            onPressed: (context) => category.reference.delete(),
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            icon: Icons.delete,
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.only(left: 16, right: 8),
        leading: SizedBox(height: double.infinity, child: Icon(category.data.icon)),
        title: Text(category.data.name),
        onTap: () => showDialog(context: context, builder: (context) => CategoryDialog.edit(category, house: house)),
      ),
    );
  }
}
