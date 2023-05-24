import 'package:flutter/material.dart';
import 'package:flutter_series/flutter_series.dart';
import 'package:house_wallet/components/ui/modal_button.dart';
import 'package:house_wallet/themes.dart';

//TODO when opened, don't cover entire screen
class CustomBottomSheet extends StatelessWidget {
  final List<Widget> body;
  final double spacing;
  final EdgeInsetsGeometry padding;
  final MainAxisSize mainAxisSize;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;
  final List<ModalButton>? actions;

  static const ShapeBorder borderRadius = RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: modalBorderRadius));

  const CustomBottomSheet({
    required this.body,
    this.spacing = 8,
    this.padding = const EdgeInsets.all(16),
    this.mainAxisSize = MainAxisSize.min,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.stretch,
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
            PadColumn(
              spacing: spacing,
              padding: padding,
              mainAxisSize: mainAxisSize,
              mainAxisAlignment: mainAxisAlignment,
              crossAxisAlignment: crossAxisAlignment,
              children: body,
            ),
            if (actions != null) PadRow(spacing: 1, children: actions!.map((button) => Expanded(child: button)).toList())
          ],
        ),
      ),
    );
  }
}
