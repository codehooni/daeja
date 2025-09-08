import 'package:daeja/ceyhun/constant_widget.dart';
import 'package:daeja/ceyhun/my_text_extension.dart';
import 'package:flutter/material.dart';

import '../widgets/my_bottom_navigation_item.dart';

import 'home_page.dart';
import 'search_page.dart';
import 'settings_page.dart';
import 'history_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    HomePage(),
    // SearchPage(),
    // HistoryPage(),
    SettingsPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomAppBar(
        // Modern Desing
        shape: const CircularNotchedRectangle(),
        notchMargin: 12.0,

        // Bottom Navigation Bar
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            MyBottomNavigationItem(
              isMe: _currentIndex == 0,
              icon: Icons.home,
              onPressed: () => _onItemTapped(0),
            ),
            // MyBottomNavigationItem(
            //   isMe: _currentIndex == 1,
            //   icon: Icons.search,
            //   onPressed: () => _onItemTapped(1),
            // ),
            SizedBox(),
            // MyBottomNavigationItem(
            //   isMe: _currentIndex == 2,
            //   icon: Icons.history,
            //   onPressed: () => _onItemTapped(2),
            // ),
            MyBottomNavigationItem(
              isMe: _currentIndex == 1,
              icon: Icons.settings,
              onPressed: () => _onItemTapped(1),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _onItemTapped(0);
        },
        shape: const CircleBorder(),
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: 'P'.text
            .size(32)
            .bold
            .color(Theme.of(context).colorScheme.onPrimary)
            .make(),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}