import 'package:flutter/material.dart';

class HomeBottomNavigation extends StatelessWidget {
  const HomeBottomNavigation({required this.onDestination, super.key});
  final ValueChanged<int> onDestination;
  @override
  Widget build(BuildContext context) => NavigationBar(
    selectedIndex: 0,
    onDestinationSelected: onDestination,
    destinations: const [
      NavigationDestination(
        icon: Icon(Icons.home_outlined),
        selectedIcon: Icon(Icons.home),
        label: 'Home',
      ),
      NavigationDestination(icon: Icon(Icons.style_outlined), label: 'Decks'),
      NavigationDestination(
        icon: Icon(Icons.play_circle_fill, size: 38),
        label: 'Play',
      ),
      NavigationDestination(icon: Icon(Icons.book_outlined), label: 'Journal'),
      NavigationDestination(icon: Icon(Icons.more_horiz), label: 'More'),
    ],
  );
}
