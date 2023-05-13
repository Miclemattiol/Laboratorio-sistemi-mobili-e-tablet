import 'package:flutter/material.dart';
import 'package:house_wallet/pages/login.dart';
import 'package:house_wallet/pages/main_page.dart';

void main() => runApp(const App());

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  bool _loggedIn = true;

  @override
  void initState() {
    super.initState();

    _loggedIn = true; //TODO Firebase Auth
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(primarySwatch: Colors.blueGrey),
      title: "HouseWallet",
      home: Scaffold(
        body: _loggedIn ? const MainPage() : const Login(),
      ),
    );
  }
}
