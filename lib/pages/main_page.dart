import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:house_wallet/data/house_data.dart';
import 'package:house_wallet/data/logged_user.dart';
import 'package:house_wallet/data/user.dart';
import 'package:house_wallet/main.dart';
import 'package:house_wallet/pages/account/account_page.dart';
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
    return StreamBuilder(
      stream: MainPage.houseFirestoreRef(LoggedUser.of(context).houseId).snapshots().map((doc) => doc.data()),
      builder: (context, snapshot) {
        final house = snapshot.data;
        return StreamBuilder(
          stream: usersFirestoreRef.where(FieldPath.documentId, whereIn: house?.users).snapshots().map(HouseDataRef.converter(house)),
          builder: (context, snapshot) {
            final house = snapshot.data;

            if (house == null) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              } else {
                return Scaffold(
                  body: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        "${localizations(context).houseDataError} (${snapshot.error})",
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                    ),
                  ),
                );
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
      PageData(
        icon: Icons.person,
        label: localizations(context).accountPage,
        widget: const AccountPage(),
      ),
      PageData(
        icon: Icons.attach_money,
        label: localizations(context).paymentsPage,
        widget: const PaymentsPage(),
      ),
      PageData(
        icon: Icons.shopping_cart,
        label: localizations(context).shoppingPage,
        widget: const ShoppingPage(),
      ),
      PageData(
        icon: Icons.assignment,
        label: localizations(context).tasksPage,
        widget: const TasksPage(),
      ),
      PageData(
        icon: Icons.groups,
        label: localizations(context).housePage,
        widget: const HousePage(),
      )
    ];
  }

  @override
  Widget build(BuildContext context) {
    final pages = _pages();
    _selectedIndex = _selectedIndex.clamp(0, pages.length - 1);
    return Scaffold(
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
        items: pages.map((page) => BottomNavigationBarItem(icon: Icon(page.icon), label: page.label)).toList(),
      ),
    );
  }
}
