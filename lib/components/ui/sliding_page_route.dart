import 'package:flutter/material.dart';

class SlidingPageRoute extends PageRouteBuilder {
  final Widget child;
  final AxisDirection direction;

  SlidingPageRoute(
    this.child, {
    AxisDirection? direction,
    super.fullscreenDialog,
  })  : direction = direction ?? (fullscreenDialog ? AxisDirection.up : AxisDirection.left),
        super(pageBuilder: (context, animation, secondaryAnimation) => child, barrierColor: Colors.black12); //TODO use Theme?

  Offset get _offset {
    switch (direction) {
      case AxisDirection.up:
        return const Offset(0, 1);
      case AxisDirection.right:
        return const Offset(-1, 0);
      case AxisDirection.down:
        return const Offset(0, -1);
      case AxisDirection.left:
        return const Offset(1, 0);
    }
  }

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) {
    return SlideTransition(
      position: animation.drive(Tween(
        begin: _offset,
        end: Offset.zero,
      ).chain(CurveTween(curve: Curves.easeInOut))),
      child: child,
    );
  }
}
