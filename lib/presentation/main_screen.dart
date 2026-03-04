import 'package:daeja/features/reservation/presentation/screens/list_screen.dart';
import 'package:daeja/presentation/map_screen.dart';
import 'package:daeja/presentation/search_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'providers/main_screen_provider.dart';

class MainScreen extends ConsumerWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(mainScreenTabIndexProvider);
    final screens = [MapScreen(), SearchScreen(), ListScreen()];

    return Scaffold(
      body: screens[currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) => ref.read(mainScreenTabIndexProvider.notifier).setTab(index),
        selectedItemColor: Colors.blue,
        backgroundColor: Colors.white,
        elevation: 4,
        enableFeedback: false,

        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.map_outlined, size: 28),
            label: '지도',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search, size: 28),
            label: '검색',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.format_list_bulleted, size: 28),
            label: '내역',
          ),
        ],
      ),
    );
  }
}
