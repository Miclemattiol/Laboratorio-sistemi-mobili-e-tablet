import 'package:flutter/material.dart';
import 'package:house_wallet/components/payments/categories/category_list_tile.dart';
import 'package:house_wallet/components/ui/app_bar_fix.dart';
import 'package:house_wallet/data/firestore.dart';
import 'package:house_wallet/data/house_data.dart';
import 'package:house_wallet/data/payments/category.dart';
import 'package:house_wallet/main.dart';
import 'package:house_wallet/pages/payments/categories/category_dialog.dart';
import 'package:house_wallet/pages/payments/payments_page.dart';
import 'package:house_wallet/themes.dart';
import 'package:house_wallet/utils.dart';
import 'package:shimmer/shimmer.dart';

class CategoriesPage extends StatelessWidget {
  final HouseDataRef house;

  const CategoriesPage({
    required this.house,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarFix(title: Text(localizations(context).categoriesPage)),
      body: StreamBuilder(
        stream: PaymentsPage.categoriesFirestoreRef(house.id).orderBy(Category.nameKey).snapshots().map(defaultFirestoreConverter),
        builder: (context, snapshot) {
          final categories = snapshot.data;

          if (categories == null) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Shimmer.fromColors(
                baseColor: Theme.of(context).disabledColor,
                highlightColor: Theme.of(context).disabledColor.withOpacity(.1),
                child: ListView(
                  children: [
                    CategoryListTile.shimmer(titleWidth: 128),
                    CategoryListTile.shimmer(titleWidth: 48),
                    CategoryListTile.shimmer(titleWidth: 80),
                    CategoryListTile.shimmer(titleWidth: 112),
                    CategoryListTile.shimmer(titleWidth: 64),
                    CategoryListTile.shimmer(titleWidth: 128),
                    CategoryListTile.shimmer(titleWidth: 96),
                  ],
                ),
              );
            } else {
              return centerErrorText(context: context, message: localizations(context).categoriesPageError, error: snapshot.error);
            }
          }

          if (categories.isEmpty) {
            return centerSectionText(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(localizations(context).categoriesPageEmpty, textAlign: TextAlign.center, style: Theme.of(context).textTheme.headlineMedium),
                  Text(localizations(context).categoriesPageEmptyDescription, textAlign: TextAlign.center, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.normal)),
                ],
              ),
            );
          }

          return ListView(
            children: categories.map((category) => CategoryListTile(category, house: house)).toList(),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: null,
        onPressed: () async {
          if (await isNotConnectedToInternet(context) || !context.mounted) return;
          showDialog(context: context, builder: (context) => CategoryDialog(house: house));
        },
        tooltip: localizations(context).categoriesPageNew,
        child: const Icon(Icons.add),
      ),
    );
  }
}
