import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:house_wallet/data/house_data.dart';
import 'package:house_wallet/data/logged_user.dart';
import 'package:house_wallet/data/shared_preferences.dart';
import 'package:house_wallet/firebase_options.dart';
import 'package:house_wallet/pages/error_page.dart';
import 'package:house_wallet/pages/login_page.dart';
import 'package:house_wallet/pages/main_page.dart';
import 'package:house_wallet/pages/no_house_page.dart';
import 'package:house_wallet/themes.dart';
import 'package:intl/intl.dart';
import 'package:keyboard_dismisser/keyboard_dismisser.dart';
import 'package:provider/provider.dart';

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
    await FirebaseAuth.instance.currentUser?.reload();
  } catch (_) {}

  prefs = await SharedPreferences.getInstance();

  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  static final groupsFirestoreReference = FirebaseFirestore.instance.collection("/groups").withConverter(fromFirestore: HouseData.fromFirestore, toFirestore: HouseData.toFirestore);

  Widget home(BuildContext context, AsyncSnapshot<LoggedUser?> snapshot) {
    final user = snapshot.data;

    if (snapshot.hasError) {
      return ErrorPage(message: localizations(context).accountPageError, error: snapshot.error);
    }

    if (user == null) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      } else {
        return const LoginPage();
      }
    }

    return Provider.value(
      value: user,
      child: user.houses.isEmpty ? const NoHousePage() : const MainPage(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardDismisser(
      child: ChangeNotifierProvider(
        create: (context) => ThemeNotifier(prefs.theme),
        child: LoggedUser.stream(builder: (context, snapshot) {
          return MaterialApp(
            title: "HouseWallet",
            theme: lightTheme,
            darkTheme: darkTheme,
            themeMode: ThemeNotifier.of(context).value,
            home: Builder(builder: (context) => home(context, snapshot)),
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
            navigatorObservers: [ClearFocusOnPush()],
          );
        }),
      ),
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
