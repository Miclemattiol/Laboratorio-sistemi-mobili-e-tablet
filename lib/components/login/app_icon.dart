import 'dart:math';

import 'package:flutter/material.dart';

class AppIcon extends StatelessWidget {
  const AppIcon({super.key});

  @override
  Widget build(BuildContext context) {
    final size = (MediaQuery.of(context).size.shortestSide - 32) / 2;
    return Center(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(size / 2),
          gradient: const LinearGradient(
            colors: [Color(0xFF50CEFF), Color(0XFF000A8F)],
            transform: GradientRotation(pi / 4),
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Image.asset("assets/splash_screen.png"),
          ),
        ),
      ),
    );
  }
}
