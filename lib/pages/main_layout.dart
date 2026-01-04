import 'package:flutter/material.dart';
import '../widgets/home_header.dart';
import '../pages/home_page.dart';
import '../pages/yoyo_page.dart';
import '../pages/cart_page.dart';
import '../pages/favorites_page.dart';
import 'profile_page.dart';
import '../widgets/bottom_nav_bar.dart';

class MainLayout extends StatefulWidget {
  final int initialIndex;
  const MainLayout({super.key, this.initialIndex = 0});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _selectedIndex = 0;

  final _pages = [
    HomePage(),
    YoYoPage(),
    CartPage(),
    FavoritesPage(),
    ProfilePage(),
  ];

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: Column(
        children: [
          if (_selectedIndex != 4)
            const HomeHeader(), // Profil sayfası index = 4 ise gösterme
          Expanded(
            child: IndexedStack(index: _selectedIndex, children: _pages),
          ),
        ],
      ),

      bottomNavigationBar: BottomNavBar(
        selectedIndex: _selectedIndex,
        onTabSelected: (index) => setState(() => _selectedIndex = index),
      ),
    );
  }
}
