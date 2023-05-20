import 'package:flutter/material.dart';
import 'package:flutter_series/flutter_series.dart';
import 'package:house_wallet/components/ui/modal_button.dart';

//TODO when opened, don't cover entire screen
class BottomSheetContainer extends StatelessWidget {
  final Widget body;
  final List<ModalButton>? actions;

  static const ShapeBorder borderRadius = RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(10)));

  const BottomSheetContainer({
    required this.body,
    this.actions,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            body,
            if (actions != null) PadRow(spacing: 1, children: actions!.map((button) => Expanded(child: button)).toList())
          ],
        ),
      ),
    );
  }
}
