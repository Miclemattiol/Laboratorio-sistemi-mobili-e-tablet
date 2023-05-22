import 'package:flutter/material.dart';
import 'package:flutter_series/flutter_series.dart';
import 'package:house_wallet/components/ui/modal_button.dart';
import 'package:house_wallet/main.dart';

class CustomDialog extends StatelessWidget {
  final List<Widget> body;
  final bool dismissible;
  final double spacing;
  final EdgeInsetsGeometry padding;
  final MainAxisSize mainAxisSize;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;
  final List<ModalButton>? actions;

  const CustomDialog({
    required this.body,
    this.dismissible = true,
    this.spacing = 8,
    this.padding = const EdgeInsets.all(16),
    this.mainAxisSize = MainAxisSize.min,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.stretch,
    this.actions,
    super.key,
  });

  static Future<void> alert({required BuildContext context, required String title, required String content}) async {
    return showDialog(
      context: context,
      builder: (context) => CustomDialog(
        padding: const EdgeInsets.all(24),
        crossAxisAlignment: CrossAxisAlignment.center,
        body: [
          Text(title, style: Theme.of(context).textTheme.headlineSmall, textAlign: TextAlign.center),
          Text(content, textAlign: TextAlign.center),
        ],
        actions: [
          ModalButton(onPressed: () => Navigator.of(context).pop(), child: Text(localizations(context).buttonOk)),
        ],
      ),
    );
  }

  static Future<bool> confirm({required BuildContext context, required String title, required String content}) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => CustomDialog(
        padding: const EdgeInsets.all(24),
        crossAxisAlignment: CrossAxisAlignment.center,
        body: [
          Text(title, style: Theme.of(context).textTheme.headlineSmall, textAlign: TextAlign.center),
          Text(content, textAlign: TextAlign.center),
        ],
        actions: [
          ModalButton(onPressed: () => Navigator.of(context).pop<bool>(false), child: Text(localizations(context).buttonNo)),
          ModalButton(onPressed: () => Navigator.of(context).pop<bool>(true), child: Text(localizations(context).buttonYes)),
        ],
      ),
    );
    return confirm ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => dismissible,
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        clipBehavior: Clip.antiAlias,
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
            if (actions != null) PadRow(spacing: 1, children: actions!.map((action) => Expanded(child: action)).toList())
          ],
        ),
      ),
    );
  }
}
