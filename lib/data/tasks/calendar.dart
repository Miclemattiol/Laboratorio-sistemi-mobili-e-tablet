import 'package:flutter/material.dart';

//TODO finish calendar
class Calendar extends StatelessWidget {
  const Calendar({super.key});

  @override
  Widget build(BuildContext context) {
    return CalendarDatePicker(
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now(),
      onDateChanged: (_) {},
    );
  }
}
