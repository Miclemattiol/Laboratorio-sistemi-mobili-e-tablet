import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:house_wallet/data/logged_user.dart';
import 'package:house_wallet/data/shared_preferences.dart';
import 'package:house_wallet/firebase_options.dart';
import 'package:house_wallet/pages/login_page.dart';
import 'package:house_wallet/pages/main_page.dart';
import 'package:house_wallet/themes.dart';
import 'package:intl/intl.dart';
import 'package:keyboard_dismisser/keyboard_dismisser.dart';

late final SharedPreferences prefs;

AppLocalizations localizations(BuildContext context) => AppLocalizations.of(context)!;
NumberFormat currencyFormat(BuildContext context) => NumberFormat("0.00 €", Localizations.localeOf(context).languageCode);
DateFormat dateFormat(BuildContext context) => DateFormat("EEEE dd MMMM, HH:mm", Localizations.localeOf(context).languageCode);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(systemNavigationBarColor: Colors.transparent),
  );

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  try {
    await LoggedUser.user?.reload();
    await LoggedUser.updateData();
  } catch (_) {}

  prefs = await SharedPreferences.getInstance();

  runApp(const App());
}

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  bool _loggedIn = LoggedUser.user != null;

  @override
  void initState() {
    super.initState();
    FirebaseAuth.instance.authStateChanges().listen((user) async {
      final loggedIn = user != null;
      if (loggedIn == _loggedIn) return;

      if (loggedIn) {
        await LoggedUser.updateData();
      }

      setState(() => _loggedIn = loggedIn);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "HouseWallet",
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: ThemeMode.system, //TODO sharedPreferences
      home: KeyboardDismisser(child: _loggedIn ? const MainPage() : const LoginPage()), //TODO handle when user isn't in any group
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale("it"),
        // Locale("en"), //TODO translations
      ],
      navigatorObservers: [
        ClearFocusOnPush()
      ],
    );
  }
}

class ClearFocusOnPush extends NavigatorObserver {
  @override
  void didPush(Route route, Route? previousRoute) {
    super.didPush(route, previousRoute);
    FocusManager.instance.primaryFocus?.unfocus();
  }
}
