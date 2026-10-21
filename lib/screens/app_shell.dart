import 'package:flutter/material.dart';

import 'explore_screen.dart';
import 'favorites_screen.dart';
import 'home_screen.dart';
import 'quiz_screens.dart';
import 'settings_screen.dart';
import 'world_screen.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key, this.initialIndex = 0});
  final int initialIndex;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  late int index = widget.initialIndex;
  final pages = const [
    HomeScreen(),
    WorldScreen(),
    ExploreScreen(),
    QuizCategoriesScreen(),
    FavoritesScreen(),
  ];

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('HISTORA'),
      actions: [
        IconButton(
          tooltip: 'Pengaturan',
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SettingsScreen()),
          ),
          icon: const Icon(Icons.settings_outlined),
        ),
      ],
    ),
    extendBody: true,
    body: SafeArea(
      top: false,
      bottom: false,
      child: IndexedStack(index: index, children: pages),
    ),
    bottomNavigationBar: NavigationBar(
      selectedIndex: index,
      onDestinationSelected: (value) => setState(() => index = value),
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home),
          label: 'Home',
        ),
        NavigationDestination(
          icon: Icon(Icons.public_outlined),
          selectedIcon: Icon(Icons.public),
          label: 'World',
        ),
        NavigationDestination(
          icon: Icon(Icons.travel_explore_outlined),
          selectedIcon: Icon(Icons.travel_explore),
          label: 'Explore',
        ),
        NavigationDestination(
          icon: Icon(Icons.quiz_outlined),
          selectedIcon: Icon(Icons.quiz),
          label: 'Kuis',
        ),
        NavigationDestination(
          icon: Icon(Icons.favorite_border),
          selectedIcon: Icon(Icons.favorite),
          label: 'Favorite',
        ),
      ],
    ),
  );
}
