import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:house_wallet/data/firestore.dart';
import 'package:house_wallet/data/house_data.dart';
import 'package:house_wallet/data/logged_user.dart';
import 'package:house_wallet/data/payments/category.dart';
import 'package:house_wallet/data/user.dart';
import 'package:house_wallet/main.dart';
import 'package:house_wallet/pages/account/account_page.dart';
import 'package:house_wallet/pages/error_page.dart';
import 'package:house_wallet/pages/house/house_page.dart';
import 'package:house_wallet/pages/payments/payments_page.dart';
import 'package:house_wallet/pages/shopping/shopping_page.dart';
import 'package:house_wallet/pages/tasks/tasks_page.dart';
import 'package:provider/provider.dart';

class PageData {
  final String label;
  final IconData icon;
  final Widget widget;

  const PageData({required this.label, required this.icon, required this.widget});
}

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  static DocumentReference<HouseData> houseFirestoreRef(String houseId) => FirebaseFirestore.instance.doc("/groups/$houseId/").withConverter(fromFirestore: HouseData.fromFirestore, toFirestore: HouseData.toFirestore);
  static CollectionReference<User> get usersFirestoreRef => FirebaseFirestore.instance.collection("/users").withConverter(fromFirestore: User.fromFirestore, toFirestore: User.toFirestore);
  static DocumentReference<User> userFirestoreRef(String userId) => usersFirestoreRef.doc(userId);

  @override
  Widget build(BuildContext context) {
    final loggedUser = LoggedUser.of(context);
    return StreamBuilder(
      stream: MainPage.houseFirestoreRef(loggedUser.houses.first).snapshots().map((doc) => FirestoreDocument(doc, doc.data()!)),
      builder: (context, snapshot) {
        final house = snapshot.data;
        return StreamBuilder(
          stream: usersFirestoreRef.where(FieldPath.documentId, whereIn: house?.data.users.keys).snapshots().map(HouseDataRef.converter(house)),
          builder: (context, snapshot) {
            final house = snapshot.data;

            if (house == null) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(body: Center(child: CircularProgressIndicator()));
              } else {
                return ErrorPage(message: localizations(context).houseDataError, error: snapshot.error);
              }
            }

            return Provider.value(
              value: house,
              child: const _MainPageStack(),
            );
          },
        );
      },
    );
  }
}

class _MainPageStack extends StatefulWidget {
  const _MainPageStack();

  @override
  State<_MainPageStack> createState() => _MainPageStackState();
}

class _MainPageStackState extends State<_MainPageStack> {
  int _selectedIndex = prefs.lastSection;

  List<PageData> _pages() {
    return [
      PageData(icon: Icons.person, label: localizations(context).accountPage, widget: const AccountPage()),
      PageData(icon: Icons.attach_money, label: localizations(context).paymentsPage, widget: Consumer<Categories?>(builder: (context, value, _) => PaymentsPage(value ?? []))),
      PageData(icon: Icons.shopping_cart, label: localizations(context).shoppingPage, widget: Consumer<Categories?>(builder: (context, value, _) => ShoppingPage(value ?? []))),
      PageData(icon: Icons.assignment, label: localizations(context).tasksPage, widget: const TasksPage()),
      PageData(icon: Icons.groups, label: localizations(context).housePage, widget: const HousePage()),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final house = HouseDataRef.of(context);
    final pages = _pages();
    _selectedIndex = _selectedIndex.clamp(0, pages.length - 1);
    return ChangeNotifierProvider(
      create: (context) => BadgesNotifier(),
      builder: (context, child) => StreamProvider<Categories?>(
        initialData: null,
        create: (context) => PaymentsPage.categoriesFirestoreRef(house.id).orderBy(Category.nameKey).snapshots().map((data) => defaultFirestoreConverter(data).toList()),
        catchError: (context, error) => null,
        child: Scaffold(
          body: IndexedStack(
            index: _selectedIndex,
            children: pages.map((page) => page.widget).toList(),
          ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: (index) {
              prefs.setLastSection(index);
              setState(() => _selectedIndex = index);
            },
            items: () {
              final badges = BadgesNotifier.of(context).badges;
              return pages.map((page) {
                final badge = badges[page.widget.runtimeType] ?? 0;
                return BottomNavigationBarItem(
                  icon: badge == 0 ? Icon(page.icon) : Badge(label: Text("$badge"), child: Icon(page.icon)),
                  label: page.label,
                );
              }).toList();
            }(),
          ),
        ),
      ),
    );
  }
}

class BadgesNotifier extends ChangeNotifier {
  static BadgesNotifier of(BuildContext context, {bool listen = true}) => Provider.of<BadgesNotifier>(context, listen: listen);

  final _badges = <Type, int>{};
  Map<Type, int> get badges => Map.unmodifiable(_badges);

  void setBadge(Type page, int? value) {
    _badges[page] = value ?? 0;
    notifyListeners();
  }

  BadgesNotifier();
}
