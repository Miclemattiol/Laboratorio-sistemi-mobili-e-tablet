import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:house_wallet/components/shopping/recipes/recipes_list_tile.dart';
import 'package:house_wallet/components/ui/app_bar_fix.dart';
import 'package:house_wallet/data/firestore.dart';
import 'package:house_wallet/data/house_data.dart';
import 'package:house_wallet/data/shopping/recipe.dart';
import 'package:house_wallet/main.dart';
import 'package:house_wallet/pages/shopping/recipes/recipe_bottom_sheet.dart';
import 'package:house_wallet/themes.dart';
import 'package:shimmer/shimmer.dart';

class RecipesPage extends StatefulWidget {
  final HouseDataRef house;

  const RecipesPage({
    required this.house,
    super.key,
  });

  static CollectionReference<Recipe> firestoreRef(String houseId) => FirebaseFirestore.instance.collection("/groups/$houseId/recipes").withConverter(fromFirestore: Recipe.fromFirestore, toFirestore: Recipe.toFirestore);

  @override
  State<RecipesPage> createState() => _RecipesPageState();
}

class _RecipesPageState extends State<RecipesPage> {
  bool _showFab = true;

  void _addRecipe(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      enableDrag: false,
      builder: (context) => RecipeBottomSheet(house: widget.house),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarFix(title: Text(localizations(context).recipesPage)),
      body: StreamBuilder(
        stream: RecipesPage.firestoreRef(widget.house.id).snapshots().map(defaultFirestoreConverter),
        builder: (context, snapshot) {
          final recipes = snapshot.data;

          if (recipes == null) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Shimmer.fromColors(
                baseColor: Theme.of(context).disabledColor,
                highlightColor: Theme.of(context).disabledColor.withOpacity(.1),
                child: ListView(
                  children: [
                    RecipeListTile.shimmer(titleWidth: 128),
                    RecipeListTile.shimmer(titleWidth: 48),
                    RecipeListTile.shimmer(titleWidth: 80),
                    RecipeListTile.shimmer(titleWidth: 112),
                    RecipeListTile.shimmer(titleWidth: 64),
                    RecipeListTile.shimmer(titleWidth: 128),
                    RecipeListTile.shimmer(titleWidth: 96),
                  ],
                ),
              );
            } else {
              return centerErrorText(context: context, message: localizations(context).recipesPageError, error: snapshot.error);
            }
          }

          if (recipes.isEmpty) {
            return centerSectionText(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(localizations(context).recipesPageEmpty, textAlign: TextAlign.center, style: Theme.of(context).textTheme.headlineMedium),
                  Text(localizations(context).recipesPageEmptyDescription, textAlign: TextAlign.center, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.normal)),
                ],
              ),
            );
          }

          return NotificationListener<UserScrollNotification>(
            onNotification: (notification) {
              setState(() => _showFab = notification.direction == ScrollDirection.idle);
              return true;
            },
            child: ListView(
              children: recipes.map((recipe) => RecipeListTile(recipe, house: widget.house)).toList(),
            ),
          );
        },
      ),
      floatingActionButton: _showFab
          ? FloatingActionButton(
              heroTag: null,
              onPressed: () => _addRecipe(context),
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}
