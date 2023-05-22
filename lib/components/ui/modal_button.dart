import 'package:flutter/material.dart';

class ModalButton extends StatelessWidget {
  final ButtonStyle? style;
  final void Function()? onPressed;
  final Widget child;

  const ModalButton({
    this.style,
    required this.onPressed,
    required this.child,
    super.key,
  });

  ButtonStyle _defaultStyle(BuildContext context) {
    //TODO normal and dangerous theme?
    final colorScheme = Theme.of(context).colorScheme;

    return TextButton.styleFrom(
      backgroundColor: colorScheme.primary,
      foregroundColor: colorScheme.onPrimary,
      disabledBackgroundColor: colorScheme.onSurface.withOpacity(0.12),
      disabledForegroundColor: colorScheme.onSurface.withOpacity(0.38),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      minimumSize: const Size.fromHeight(40),
    );
  }

  @override
  Widget build(BuildContext context) {
    return TextButton(
      style: (style ?? TextButton.styleFrom()).merge(_defaultStyle(context)),
      onPressed: onPressed,
      child: child,
    );
  }
}
