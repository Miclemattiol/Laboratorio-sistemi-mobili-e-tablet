import 'package:flutter/material.dart';
import 'package:flutter_series/flutter_series.dart';
import 'package:house_wallet/components/form/date_picker_form_field.dart';
import 'package:house_wallet/components/form/number_form_field.dart';
import 'package:house_wallet/components/form/people_form_field.dart';
import 'package:house_wallet/components/ui/custom_bottom_sheet.dart';
import 'package:house_wallet/components/ui/modal_button.dart';
import 'package:house_wallet/data/house_data.dart';
import 'package:house_wallet/data/payments/payment_filter.dart';
import 'package:house_wallet/main.dart';
import 'package:house_wallet/themes.dart';

//TODO filter
class FilterBottomSheet extends StatefulWidget {
  final HouseDataRef house;
  PaymentFilter filter;

  FilterBottomSheet({
    required this.house,
    required this.filter,
    super.key,
  });

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  final TextEditingController _minPriceController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  _saveFilter() {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();
    Navigator.of(context).pop(widget.filter);
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
                decoration: inputDecoration(localizations(context).paymentFilterTitle),
                initialValue: widget.filter.titleShouldMatch,
                onSaved: (value) => widget.filter.titleShouldMatch = value,
              ),
              TextFormField(
                decoration: inputDecoration(localizations(context).paymentFilterDescription),
                initialValue: widget.filter.descriptionShouldMatch,
                onSaved: (value) => widget.filter.descriptionShouldMatch = value,
              ),
              DropdownButtonHideUnderline(
                child: DropdownButton(
                  isExpanded: true,
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
                  onChanged: (value) {
                    //TODO implement categories
                  },
                  value: localizations(context).paymentCategory,
                ),
              ),
              PeopleFormField(
                house: widget.house,
                decoration: inputDecoration(localizations(context).paymentPaidFrom("")),
                onSaved: (value) => widget.filter.fromUser = value,
              ),
              PeopleFormField(
                house: widget.house,
                decoration: inputDecoration(localizations(context).peopleShares),
                onSaved: (value) => widget.filter.toUser = value,
              ),
              PadRow(
                spacing: 16,
                children: [
                  Expanded(
                    child: NumberFormField(
                      decoration: inputDecoration(localizations(context).paymentFilterMinPrice),
                      controller: _minPriceController,
                    ),
                  ),
                  Expanded(
                    child: NumberFormField<double>(
                      decoration: inputDecoration(localizations(context).paymentFilterMaxPrice).copyWith(errorMaxLines: 3),
                      validator: (value) {
                        if (value != null && double.parse(_minPriceController.value.text) > value) {
                          return localizations(context).paymentFilterMaxPriceError;
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              DatePickerFormField.dateOnly(
                decoration: inputDecoration(localizations(context).paymentFilterFromDate),
                onSaved: (value) => widget.filter.fromDate = value,
              ),
              DatePickerFormField.dateOnly(
                decoration: inputDecoration(localizations(context).paymentFilterToDate),
                onSaved: (value) => widget.filter.toDate = value,
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
