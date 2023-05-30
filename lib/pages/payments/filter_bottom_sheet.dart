import 'package:flutter/material.dart';
import 'package:flutter_series/flutter_series.dart';
import 'package:house_wallet/components/form/date_picker_form_field.dart';
import 'package:house_wallet/components/form/number_form_field.dart';
import 'package:house_wallet/components/form/people_form_field.dart';
import 'package:house_wallet/components/ui/custom_bottom_sheet.dart';
import 'package:house_wallet/components/ui/modal_button.dart';
import 'package:house_wallet/data/house_data.dart';
import 'package:house_wallet/main.dart';
import 'package:house_wallet/themes.dart';
import 'package:house_wallet/utils.dart';

class PaymentFilter {
  String? titleShouldMatch;
  String? descriptionShouldMatch; //TODO non ricordo perché lo avessi messo
  Set<String>? categoryId;
  Set<String>? fromUser;
  Set<String>? toUser;
  NumRange? priceRange;
  DateRange? dateRange;
  String? shouldMatch;
  bool? andOr; //TODO not used?

  PaymentFilter({
    this.titleShouldMatch,
    this.descriptionShouldMatch,
    this.categoryId,
    this.fromUser,
    this.toUser,
    this.priceRange,
    this.dateRange,
    this.shouldMatch,
  });
}

class FilterBottomSheet extends StatefulWidget {
  final HouseDataRef house;
  final PaymentFilter currentFilter;

  const FilterBottomSheet({
    required this.house,
    required this.currentFilter,
    super.key,
  });

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  final _formKey = GlobalKey<FormState>();

  String? _titleValue;
  String? _descriptionValue;
  Set<String>? _categoryValue;
  Set<String>? _fromUserValue;
  Set<String>? _toUserValue;
  num? _minPriceValue;
  num? _maxPriceValue;
  DateTime? _fromDateValue;
  DateTime? _toDateValue;

  _saveFilter() {
    _formKey.currentState!.save();
    if (!_formKey.currentState!.validate()) return;

    Navigator.of(context).pop<PaymentFilter>(PaymentFilter(
      titleShouldMatch: _titleValue,
      descriptionShouldMatch: _descriptionValue,
      categoryId: _categoryValue,
      fromUser: _fromUserValue,
      toUser: _toUserValue,
      priceRange: NumRange(_minPriceValue, _maxPriceValue),
      dateRange: DateRange(_fromDateValue, _toDateValue),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return CustomBottomSheet(
      body: [
        Form(
          key: _formKey,
          child: PadColumn(
            spacing: 16,
            children: [
              TextFormField(
                initialValue: widget.currentFilter.titleShouldMatch,
                decoration: inputDecoration(localizations(context).paymentFilterTitle),
                onSaved: (title) => _titleValue = title,
              ),
              TextFormField(
                initialValue: widget.currentFilter.descriptionShouldMatch,
                decoration: inputDecoration(localizations(context).paymentFilterDescription),
                onSaved: (description) => _descriptionValue = description,
              ),
              DropdownButton(
                //TODO implement categories (create new component CategoriesFormField)
                value: localizations(context).paymentCategory,
                isExpanded: true,
                style: Theme.of(context).textTheme.bodyMedium,
                underline: const SizedBox.shrink(),
                items: [
                  DropdownMenuItem(
                    value: localizations(context).paymentCategory,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(localizations(context).paymentCategory),
                        const Icon(Icons.new_label_outlined)
                      ],
                    ),
                  ),
                ],
                onChanged: null,
              ),
              PeopleFormField(
                initialValue: widget.currentFilter.fromUser,
                house: widget.house,
                decoration: inputDecoration(localizations(context).paymentPaidFrom("")),
                onSaved: (fromUser) => _fromUserValue = fromUser,
              ),
              PeopleFormField(
                initialValue: widget.currentFilter.toUser,
                house: widget.house,
                decoration: inputDecoration(localizations(context).peopleShares),
                onSaved: (toUser) => _toUserValue = toUser,
              ),
              PadRow(
                spacing: 16,
                children: [
                  Expanded(
                    child: NumberFormField(
                      initialValue: widget.currentFilter.priceRange?.start,
                      decoration: inputDecoration(localizations(context).paymentFilterMinPrice),
                      decimal: true,
                      validator: (minPrice) => (minPrice != null && _maxPriceValue != null && _maxPriceValue! < minPrice) ? localizations(context).paymentFilterMinPriceError : null,
                      onSaved: (minPrice) => _minPriceValue = minPrice,
                    ),
                  ),
                  Expanded(
                    child: NumberFormField(
                      initialValue: widget.currentFilter.priceRange?.end,
                      decoration: inputDecoration(localizations(context).paymentFilterMaxPrice).copyWith(errorMaxLines: 3),
                      decimal: true,
                      validator: (maxPrice) => (maxPrice != null && _minPriceValue != null && _minPriceValue! > maxPrice) ? localizations(context).paymentFilterMaxPriceError : null,
                      onSaved: (maxPrice) => _maxPriceValue = maxPrice,
                    ),
                  ),
                ],
              ),
              DatePickerFormField.dateOnly(
                initialValue: widget.currentFilter.dateRange?.start,
                decoration: inputDecoration(localizations(context).paymentFilterFromDate),
                firstDate: DateTime(DateTime.now().year - 10),
                validator: (fromDate) => (fromDate != null && (_toDateValue?.isBefore(fromDate) ?? false)) ? localizations(context).taskStartDateInputErrorAfterEndDate : null,
                onSaved: (fromDate) => _fromDateValue = fromDate,
              ),
              DatePickerFormField.dateOnly(
                initialValue: widget.currentFilter.dateRange?.end,
                firstDate: DateTime(DateTime.now().year - 10),
                decoration: inputDecoration(localizations(context).paymentFilterToDate),
                validator: (toDate) => (toDate != null && (_fromDateValue?.isAfter(toDate) ?? false)) ? localizations(context).taskEndDateInputErrorBeforeStartDate : null,
                onSaved: (toDate) => _toDateValue = toDate,
              ),
            ],
          ),
        ),
      ],
      actions: [
        ModalButton(onPressed: () => Navigator.of(context).pop(), child: Text(localizations(context).buttonCancel)),
        ModalButton(onPressed: () => _saveFilter(), child: Text(localizations(context).buttonOk)),
      ],
    );
  }
}
