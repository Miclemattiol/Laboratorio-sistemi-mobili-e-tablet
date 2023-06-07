import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:house_wallet/components/form/recipe_form_field.dart';
import 'package:house_wallet/components/ui/custom_bottom_sheet.dart';
import 'package:house_wallet/components/ui/custom_dialog.dart';
import 'package:house_wallet/components/ui/modal_button.dart';
import 'package:house_wallet/data/firestore.dart';
import 'package:house_wallet/data/house_data.dart';
import 'package:house_wallet/data/shopping/recipe.dart';
import 'package:house_wallet/main.dart';
import 'package:house_wallet/pages/shopping/recipes/recipes_page.dart';
import 'package:house_wallet/themes.dart';
import 'package:house_wallet/utils.dart';

class RecipeBottomSheet extends StatefulWidget {
  final HouseDataRef house;
  final FirestoreDocument<Recipe>? recipe;
  final List<RecipeItem>? initialItems;

  const RecipeBottomSheet({
    required this.house,
    super.key,
  })  : recipe = null,
        initialItems = null;

  const RecipeBottomSheet.quickAddRecipe(
    List<RecipeItem> this.initialItems, {
    required this.house,
    super.key,
  }) : recipe = null;

  const RecipeBottomSheet.edit(
    FirestoreDocument<Recipe> this.recipe, {
    required this.house,
    super.key,
  }) : initialItems = null;

  @override
  State<RecipeBottomSheet> createState() => _RecipeBottomSheetState();
}

class _RecipeBottomSheetState extends State<RecipeBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  bool _loading = false;

  String? _titleValue;
  List<RecipeItem>? _itemsValue;

  void _saveRecipe() async {
    final navigator = Navigator.of(context);

    _formKey.currentState!.save();
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    try {
      if (await isNotConnectedToInternet(context) || !mounted) return mounted ? setState(() => _loading = false) : null;

      if (widget.recipe == null) {
        await RecipesPage.firestoreRef(widget.house.id).add(Recipe(
          title: _titleValue!,
          items: _itemsValue!,
        ));
      } else {
        await widget.recipe!.reference.update({
          Recipe.titleKey: _titleValue!,
          Recipe.itemsKey: _itemsValue!.map((item) => item.toJson()),
        });
      }

      navigator.pop();
    } on FirebaseException catch (error) {
      if (!context.mounted) return;
      CustomDialog.alert(
        context: context,
        title: localizations(context).error,
        content: localizations(context).saveChangesError(error.message.toString()),
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
          TextFormField(
            enabled: !_loading,
            autofocus: widget.recipe?.data.title == null,
            initialValue: widget.recipe?.data.title,
            decoration: inputDecoration(localizations(context).title),
            onSaved: (title) => _titleValue = title.toNullable(),
            validator: (value) => value?.trim().isEmpty == true ? localizations(context).titleMissing : null,
          ),
          RecipeFormField(
            enabled: !_loading,
            initialValue: widget.initialItems ?? widget.recipe?.data.items,
            decoration: inputDecoration(localizations(context).recipeItems),
            onSaved: (items) => _itemsValue = items,
            validator: (items) => items.isEmpty ? localizations(context).recipeItemsMissing : null,
          ),
        ],
        actions: [
          ModalButton(enabled: !_loading, onPressed: () => Navigator.of(context).pop(), child: Text(localizations(context).cancel)),
          ModalButton(enabled: !_loading, onPressed: _saveRecipe, child: Text(localizations(context).ok)),
        ],
      ),
    );
  }
}
