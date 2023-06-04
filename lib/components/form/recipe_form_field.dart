import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:house_wallet/components/shopping/recipes/recipe_item_list_tile.dart';
import 'package:house_wallet/data/shopping/recipe.dart';
import 'package:house_wallet/pages/shopping/recipes/recipe_item_dialog.dart';

class RecipeFormField extends StatelessWidget {
  final List<RecipeItem>? initialValue;
  final AutovalidateMode? autovalidateMode;
  final InputDecoration? decoration;
  final String? Function(List<RecipeItem> value)? validator;
  final void Function(List<RecipeItem> value)? onSaved;
  final void Function(List<RecipeItem> value)? onChanged;
  final bool enabled;

  const RecipeFormField({
    this.initialValue,
    this.autovalidateMode,
    this.decoration,
    this.validator,
    this.onSaved,
    this.onChanged,
    this.enabled = true,
    super.key,
  });

  void _addNewItem(BuildContext context, FormFieldState<List<RecipeItem>> state) async {
    final newRecipe = await showDialog<RecipeItem>(context: context, builder: (context) => const RecipeItemDialog());
    if (newRecipe == null) return;

    state.didChange(state.value!..add(newRecipe));
  }

  void _editItem(BuildContext context, FormFieldState<List<RecipeItem>> state, int index, RecipeItem recipe) async {
    final newRecipe = await showDialog<RecipeItem>(context: context, builder: (context) => RecipeItemDialog(initialValue: recipe));
    if (newRecipe == null) return;

    state.didChange(state.value!..[index] = newRecipe);
  }

  void _deleteItem(FormFieldState<List<RecipeItem>> state, int index) {
    state.didChange(state.value!..removeAt(index));
  }

  @override
  Widget build(BuildContext context) {
    return FormField<List<RecipeItem>>(
      initialValue: List.from(initialValue ?? []),
      autovalidateMode: autovalidateMode,
      validator: (value) => validator?.call(value ?? []),
      onSaved: (newValue) => onSaved?.call(newValue ?? []),
      enabled: enabled,
      builder: (state) {
        return GestureDetector(
          child: InputDecorator(
            decoration: (decoration ?? const InputDecoration()).copyWith(
              border: const OutlineInputBorder(),
              enabled: enabled,
              errorText: decoration?.errorText ?? state.errorText,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            child: Column(
              children: [
                ...state.value!.mapIndexed((index, recipe) {
                  return RecipeItemListTile(
                    key: Key("$index${recipe.hashCode}"),
                    enabled: enabled,
                    recipe,
                    onPressed: () => _editItem(context, state, index, recipe),
                    onDelete: () => _deleteItem(state, index),
                  );
                }),
                RecipeItemListTile.createNew(enabled: enabled, onPressed: enabled ? () => _addNewItem(context, state) : null),
              ],
            ),
          ),
        );
      },
    );
  }
}
