import 'package:flutter/material.dart';

class CollapsibleContainer extends StatelessWidget {
  final bool collapsed;
  final Widget child;
  final Duration duration;
  final Curve curve;
  final Axis axis;

  const CollapsibleContainer({
    required this.collapsed,
    required this.child,
    this.duration = const Duration(milliseconds: 200),
    this.curve = Curves.easeInOut,
    this.axis = Axis.vertical,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: duration,
      switchInCurve: curve,
      switchOutCurve: curve,
      transitionBuilder: (child, animation) => SizeTransition(sizeFactor: animation, axis: axis, child: child),
      child: collapsed ? null : child,
    );
  }
}
