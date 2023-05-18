import 'package:flutter/material.dart';
import 'package:house_wallet/main.dart';
import 'package:house_wallet/pages/account/account_page.dart';
import 'package:house_wallet/pages/house/house_page.dart';
import 'package:house_wallet/pages/shopping_page.dart';
import 'package:house_wallet/pages/tasks/tasks_page.dart';
import 'package:house_wallet/pages/transactions/transactions_page.dart';

class PageData {
  final String label;
  final IconData icon;
  final Widget widget;

  const PageData({required this.label, required this.icon, required this.widget});
}

List<PageData> _pages(BuildContext context) {
  return [
    PageData(
      icon: Icons.person,
      label: localizations(context).accountPage,
      widget: const AccountPage(),
    ),
    PageData(
      icon: Icons.attach_money,
      label: localizations(context).transactionsPage,
      widget: const TransactionsPage(),
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

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final pages = _pages(context);
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: pages.map((page) => page.widget).toList(),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: pages.map((page) {
          return BottomNavigationBarItem(
            icon: Icon(page.icon),
            label: page.label,
            backgroundColor: Theme.of(context).primaryColor,
          );
        }).toList(),
      ),
    );
  }
}
