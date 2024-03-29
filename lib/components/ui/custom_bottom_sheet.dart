import 'package:flutter/material.dart';
import 'package:flutter_series/flutter_series.dart';
import 'package:house_wallet/components/ui/modal_button.dart';

class CustomBottomSheet extends StatelessWidget {
  final List<Widget> body;
  final bool dismissible;
  final BoxDecoration? decoration;
  final double spacing;
  final EdgeInsetsGeometry padding;
  final MainAxisSize mainAxisSize;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;
  final List<ModalButton>? actions;

  const CustomBottomSheet({
    required this.body,
    this.dismissible = true,
    this.decoration,
    this.spacing = 8,
    this.padding = const EdgeInsets.all(16),
    this.mainAxisSize = MainAxisSize.min,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.stretch,
    this.actions,
    super.key,
  });

  BorderRadiusGeometry? borderRadius(BuildContext context) {
    try {
      return (Theme.of(context).bottomSheetTheme.shape as RoundedRectangleBorder).borderRadius;
    } catch (_) {
      return BorderRadius.circular(10);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * .9),
      child: WillPopScope(
        onWillPop: () async => dismissible,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
            child: Container(
              clipBehavior: Clip.antiAlias,
              decoration: (decoration ?? const BoxDecoration()).copyWith(borderRadius: decoration?.borderRadius ?? borderRadius(context)),
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
          ),
        ),
      ),
    );
  }
}
