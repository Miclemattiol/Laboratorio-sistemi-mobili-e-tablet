import 'package:flutter/material.dart';
import 'package:house_wallet/pages/casa/casa.dart';
import 'package:house_wallet/pages/incarichi/incarichi.dart';
import 'package:house_wallet/pages/profilo.dart';
import 'package:house_wallet/pages/spesa.dart';
import 'package:house_wallet/pages/transazioni.dart';

class PageData {
  final String label;
  final IconData icon;
  final Widget widget;

  const PageData({required this.label, required this.icon, required this.widget});
}

const _pages = <PageData>[
  PageData(
    icon: Icons.person,
    label: Profilo.label,
    widget: Profilo(),
  ),
  PageData(
    icon: Icons.attach_money,
    label: Transazioni.label,
    widget: Transazioni(),
  ),
  PageData(
    icon: Icons.shopping_cart,
    label: Spesa.label,
    widget: Spesa(),
  ),
  PageData(
    icon: Icons.assignment,
    label: Incarichi.label,
    widget: Incarichi(),
  ),
  PageData(
    icon: Icons.groups,
    label: Casa.label,
    widget: Casa(),
  )
];

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages.map((page) => page.widget).toList(),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: [
          ..._pages.map(
            (page) => BottomNavigationBarItem(
              icon: Icon(page.icon),
              label: page.label,
              backgroundColor: Theme.of(context).primaryColor,
            ),
          )
        ],
      ),
    );
  }
}
