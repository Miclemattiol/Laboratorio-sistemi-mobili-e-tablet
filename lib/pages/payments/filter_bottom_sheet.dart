import 'package:flutter/material.dart';
import 'package:flutter_series/flutter_series.dart';
import 'package:house_wallet/components/form/categories_form_field.dart';
import 'package:house_wallet/components/form/date_picker_form_field.dart';
import 'package:house_wallet/components/form/dropdown_form_field.dart';
import 'package:house_wallet/components/form/number_form_field.dart';
import 'package:house_wallet/components/form/people_form_field.dart';
import 'package:house_wallet/components/ui/custom_bottom_sheet.dart';
import 'package:house_wallet/components/ui/modal_button.dart';
import 'package:house_wallet/data/firestore.dart';
import 'package:house_wallet/data/house_data.dart';
import 'package:house_wallet/data/payment_or_trade.dart';
import 'package:house_wallet/data/payments/category.dart';
import 'package:house_wallet/data/payments/payment.dart';
import 'package:house_wallet/data/payments/trade.dart';
import 'package:house_wallet/main.dart';
import 'package:house_wallet/themes.dart';
import 'package:house_wallet/utils.dart';

class PaymentFilter {
  final String title;
  final String description;
  final Set<String> categories;
  final Set<String> fromUsers;
  final Set<String> toUsers;
  final Range<num> priceRange;
  final Range<DateTime> dateRange;

  const PaymentFilter({
    required this.title,
    required this.description,
    required this.categories,
    required this.fromUsers,
    required this.toUsers,
    required this.priceRange,
    required this.dateRange,
  });

  const PaymentFilter.empty()
      : title = "",
        description = "",
        categories = const {},
        fromUsers = const {},
        toUsers = const {},
        priceRange = const Range.empty(),
        dateRange = const Range.empty();

  bool get isEmpty {
    return title.isEmpty && description.isEmpty && categories.isEmpty && fromUsers.isEmpty && toUsers.isEmpty && priceRange.isEmpty && dateRange.isEmpty;
  }

  List<FirestoreDocument<PaymentOrTrade>> filterData(List<FirestoreDocument<PaymentOrTrade>> data) {
    return data.where((element) {
      if (description.isNotEmpty && !element.data.description.containsCaseUnsensitive(description)) return false;
      if (fromUsers.isNotEmpty && !fromUsers.contains(element.data.from.uid)) return false;
      if (!priceRange.test(element.data.price)) return false;
      if (!dateRange.test(element.data.date)) return false;

      if (element.data is PaymentRef) {
        final payment = element.data as PaymentRef;
        if (title.isNotEmpty && !payment.title.containsCaseUnsensitive(title)) return false;
        if (categories.isNotEmpty && !categories.contains(payment.category?.id)) return false;
        if (toUsers.isNotEmpty && toUsers.intersection(payment.to.keys.toSet()).isEmpty) return false;
      } else {
        final trade = element.data as TradeRef;
        if (title.isNotEmpty) return false;
        if (categories.isNotEmpty) return false;
        if (toUsers.isNotEmpty && !toUsers.contains(trade.to.uid)) return false;
      }

      return true;
    }).toList();
  }
}

class FilterBottomSheet extends StatefulWidget {
  final HouseDataRef house;
  final PaymentFilter currentFilter;
  final List<FirestoreDocument<Category>> categories;

  const FilterBottomSheet({
    required this.house,
    required this.currentFilter,
    required this.categories,
    super.key,
  });

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  final _formKey = GlobalKey<FormState>();

  String? _titleValue;
  String? _descriptionValue;
  Set<String>? _categoriesValue;
  Set<String>? _fromUserValue;
  Set<String>? _toUserValue;
  num? _minPriceValue;
  num? _maxPriceValue;
  DateTime? _fromDateValue;
  DateTime? _toDateValue;

  late bool _titleFieldEnabled = widget.currentFilter.title.isNotEmpty;
  late bool _descriptionFieldEnabled = widget.currentFilter.description.isNotEmpty;
  late bool _categoriesFieldEnabled = widget.currentFilter.categories.isNotEmpty;
  late bool _fromUserFieldEnabled = widget.currentFilter.fromUsers.isNotEmpty;
  late bool _toUserFieldEnabled = widget.currentFilter.toUsers.isNotEmpty;
  late bool _priceRangeFieldEnabled = !widget.currentFilter.priceRange.isEmpty;
  late bool _dateRangeFieldEnabled = !widget.currentFilter.dateRange.isEmpty;

  _saveFilter() {
    _formKey.currentState!.save();
    if (!_formKey.currentState!.validate()) return;

    Navigator.of(context).pop<PaymentFilter>(PaymentFilter(
      title: _titleValue ?? "",
      description: _descriptionValue ?? "",
      categories: _categoriesValue ?? {},
      fromUsers: _fromUserValue ?? {},
      toUsers: _toUserValue ?? {},
      priceRange: Range(_minPriceValue, _maxPriceValue),
      dateRange: Range(_fromDateValue, _toDateValue),
    ));
  }

  _titleField() {
    return TextFormField(
      initialValue: widget.currentFilter.title,
      decoration: inputDecoration(localizations(context).title),
      onSaved: (title) => _titleValue = title.nullTrim(),
    );
  }

  _descriptionField() {
    return TextFormField(
      initialValue: widget.currentFilter.description,
      decoration: inputDecoration(localizations(context).description),
      onSaved: (description) => _descriptionValue = description.nullTrim(),
    );
  }

  _categoriesField() {
    return CategoriesFormField(
      values: widget.categories,
      initialValues: widget.currentFilter.categories,
      decoration: inputDecoration(localizations(context).categoriesPage),
      onSaved: (categories) => _categoriesValue = categories,
    );
  }

  _fromUserField() {
    return PeopleFormField(
      initialValue: widget.currentFilter.fromUsers,
      house: widget.house,
      decoration: inputDecoration(localizations(context).paidBy),
      onSaved: (fromUser) => _fromUserValue = fromUser,
    );
  }

  _toUserField() {
    return PeopleFormField(
      initialValue: widget.currentFilter.toUsers,
      house: widget.house,
      decoration: inputDecoration(localizations(context).paidFor),
      onSaved: (toUser) => _toUserValue = toUser,
    );
  }

  _priceRangeField() {
    return PadRow(
      spacing: 16,
      children: [
        Expanded(
          child: NumberFormField(
            initialValue: widget.currentFilter.priceRange.start,
            decoration: inputDecoration(localizations(context).rangeMinPrice),
            decimal: true,
            validator: (minPrice) => (minPrice != null && _maxPriceValue != null && _maxPriceValue! < minPrice) ? localizations(context).rangeMinPriceError : null,
            onSaved: (minPrice) => _minPriceValue = minPrice,
          ),
        ),
        Expanded(
          child: NumberFormField(
            initialValue: widget.currentFilter.priceRange.end,
            decoration: inputDecoration(localizations(context).rangeMaxPrice).copyWith(errorMaxLines: 3),
            decimal: true,
            validator: (maxPrice) => (maxPrice != null && _minPriceValue != null && _minPriceValue! > maxPrice) ? localizations(context).rangeMaxPriceError : null,
            onSaved: (maxPrice) => _maxPriceValue = maxPrice,
          ),
        ),
      ],
    );
  }

  _dateRangeField() {
    return PadColumn(
      spacing: 16,
      children: [
        DatePickerFormField.dateOnly(
          initialValue: widget.currentFilter.dateRange.start,
          decoration: inputDecoration(localizations(context).rangeStartDate),
          firstDate: DateTime(DateTime.now().year - 10),
          validator: (fromDate) => (fromDate != null && (_toDateValue?.isBefore(fromDate) ?? false)) ? localizations(context).rangeStartDateInvalid : null,
          onSaved: (fromDate) => _fromDateValue = fromDate,
        ),
        DatePickerFormField.dateOnly(
          initialValue: widget.currentFilter.dateRange.end,
          firstDate: DateTime(DateTime.now().year - 10),
          decoration: inputDecoration(localizations(context).rangeEndDate),
          validator: (toDate) => (toDate != null && (_fromDateValue?.isAfter(toDate) ?? false)) ? localizations(context).rangeEndDateInvalid : null,
          onSaved: (toDate) => _toDateValue = toDate,
        ),
      ],
    );
  }

  _buildDropdownItem(String text, Icon icon) {
    return PadRow(
      spacing: 16,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        icon,
        Text(text),
      ],
    );
  }

  _buildFilterWidget(Widget widget, Function() onRemoved) {
    return PadRow(
      spacing: 16,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: widget,
        ),
        GestureDetector(
          onTap: onRemoved,
          child: const Icon(Icons.highlight_remove),
        ),
      ],
    );
  }

  //define key for DropdownFormField
  final dropdownFormField = GlobalKey<FormFieldState>();

  @override
  Widget build(BuildContext context) {
    return CustomBottomSheet(
      body: [
        Form(
          key: _formKey,
          child: PadColumn(
            spacing: 16,
            children: [
              if (_titleFieldEnabled) _buildFilterWidget(_titleField(), () => setState(() => _titleFieldEnabled = false)),
              if (_descriptionFieldEnabled) _buildFilterWidget(_descriptionField(), () => setState(() => _descriptionFieldEnabled = false)),
              if (_categoriesFieldEnabled) _buildFilterWidget(_categoriesField(), () => setState(() => _categoriesFieldEnabled = false)),
              if (_fromUserFieldEnabled) _buildFilterWidget(_fromUserField(), () => setState(() => _fromUserFieldEnabled = false)),
              if (_toUserFieldEnabled) _buildFilterWidget(_toUserField(), () => setState(() => _toUserFieldEnabled = false)),
              if (_priceRangeFieldEnabled) _buildFilterWidget(_priceRangeField(), () => setState(() => _priceRangeFieldEnabled = false)),
              if (_dateRangeFieldEnabled) _buildFilterWidget(_dateRangeField(), () => setState(() => _dateRangeFieldEnabled = false)),
              if (!_titleFieldEnabled || !_descriptionFieldEnabled || !_categoriesFieldEnabled || !_fromUserFieldEnabled || !_toUserFieldEnabled || !_priceRangeFieldEnabled || !_dateRangeFieldEnabled)
                DropdownFormField<String>(
                  dropdownWidgetKey: dropdownFormField,
                  initialValue: localizations(context).filterTooltip,
                  items: Map.fromEntries(
                    [
                      if (!_titleFieldEnabled)
                        MapEntry(
                          localizations(context).title,
                          _buildDropdownItem(
                            localizations(context).title,
                            const Icon(Icons.title),
                          ),
                        ),
                      if (!_descriptionFieldEnabled)
                        MapEntry(
                          localizations(context).description,
                          _buildDropdownItem(
                            localizations(context).description,
                            const Icon(Icons.description),
                          ),
                        ),
                      if (!_categoriesFieldEnabled)
                        MapEntry(
                          localizations(context).categoriesPage,
                          _buildDropdownItem(
                            localizations(context).categoriesPage,
                            const Icon(Icons.category),
                          ),
                        ),
                      if (!_fromUserFieldEnabled)
                        MapEntry(
                          localizations(context).paidBy,
                          _buildDropdownItem(
                            localizations(context).paidBy,
                            const Icon(Icons.person),
                          ),
                        ),
                      if (!_toUserFieldEnabled)
                        MapEntry(
                          localizations(context).paidFor,
                          _buildDropdownItem(
                            localizations(context).paidFor,
                            const Icon(Icons.people),
                          ),
                        ),
                      if (!_priceRangeFieldEnabled)
                        MapEntry(
                          localizations(context).priceRange,
                          _buildDropdownItem(
                            localizations(context).priceRange,
                            // "Price Range",
                            const Icon(Icons.attach_money),
                          ),
                        ),
                      if (!_dateRangeFieldEnabled)
                        MapEntry(
                          localizations(context).dateRange,
                          _buildDropdownItem(
                            localizations(context).dateRange,
                            // "Date Range",
                            const Icon(Icons.calendar_today),
                          ),
                        ),
                      MapEntry(localizations(context).filterTooltip, _buildDropdownItem(localizations(context).filterTooltip, const Icon(Icons.filter_alt))),
                    ],
                  ),
                  onChanged: (value) {
                    if (value == localizations(context).filterTooltip) return;
                    if (value == localizations(context).title) {
                      setState(() => _titleFieldEnabled = true);
                    } else if (value == localizations(context).description) {
                      setState(() => _descriptionFieldEnabled = true);
                    } else if (value == localizations(context).categoriesPage) {
                      setState(() => _categoriesFieldEnabled = true);
                    } else if (value == localizations(context).paidBy) {
                      setState(() => _fromUserFieldEnabled = true);
                    } else if (value == localizations(context).paidFor) {
                      setState(() => _toUserFieldEnabled = true);
                    } else if (value == localizations(context).priceRange) {
                      setState(() => _priceRangeFieldEnabled = true);
                    } else if (value == localizations(context).dateRange) {
                      setState(() => _dateRangeFieldEnabled = true);
                    }
                    //set dropdownFormField value to default value
                    dropdownFormField.currentState!.didChange(localizations(context).filterTooltip);
                  },
                )
            ],
          ),
        ),
      ],
      actions: [
        ModalButton(onPressed: () => Navigator.of(context).pop(), child: Text(localizations(context).cancel)),
        ModalButton(onPressed: () => _saveFilter(), child: Text(localizations(context).ok)),
      ],
    );
  }
}
