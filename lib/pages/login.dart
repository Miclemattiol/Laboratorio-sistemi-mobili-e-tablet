import 'package:flutter/material.dart';
import 'package:house_wallet/components/ui/app_bar_fix.dart';

class Login extends StatelessWidget {
  const Login({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarFix(title: const Text("Login")),
      body: const Center(child: Text("Login")),
    );
  }
}
