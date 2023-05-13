import 'package:flutter/material.dart';
import 'package:house_wallet/pages/casa.dart';
import 'package:house_wallet/pages/incarichi.dart';
import 'package:house_wallet/pages/profilo.dart';
import 'package:house_wallet/pages/spesa.dart';
import 'package:house_wallet/pages/transazioni.dart';

class Page {
  final String label;
  final IconData icon;
  final Widget widget;

  const Page({required this.label, required this.icon, required this.widget});
}

const _pages = <Page>[
  Page(
    icon: Icons.person,
    label: Profilo.label,
    widget: Profilo(),
  ),
  Page(
    icon: Icons.attach_money,
    label: Transazioni.label,
    widget: Transazioni(),
  ),
  Page(
    icon: Icons.shopping_cart,
    label: Spesa.label,
    widget: Spesa(),
  ),
  Page(
    icon: Icons.assignment,
    label: Incarichi.label,
    widget: Incarichi(),
  ),
  Page(
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
