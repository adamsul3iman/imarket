import 'package:flutter/material.dart';
import 'package:imarket/presentation/screens/dashboard_screen.dart';
import 'package:imarket/presentation/screens/favorites_screen.dart';
import 'package:imarket/presentation/screens/home_screen.dart';
import 'package:imarket/presentation/screens/profile_screen.dart';

/// الشاشة الرئيسية التي تحتوي على شريط التنقل السفلي (BottomNavBar) وتستضيف الشاشات الرئيسية الأخرى.
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  void _navigateToHome() {
    setState(() {
      _selectedIndex = 0;
    });
  }

  @override
  @override
  Widget build(BuildContext context) {
    // ✅ FIX: The list now contains the simple FavoritesScreen()
    final List<Widget> screens = <Widget>[
      const HomeScreen(),
      const FavoritesScreen(), // No parameters needed
      const DashboardScreen(),
      const ProfileScreen(),
    ];
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'الرئيسية'),
          BottomNavigationBarItem(
              icon: Icon(Icons.favorite_border),
              activeIcon: Icon(Icons.favorite),
              label: 'المفضلة'),
          BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_outlined),
              activeIcon: Icon(Icons.dashboard),
              label: 'لوحة التحكم'),
          BottomNavigationBarItem(
              icon: Icon(Icons.person_outlined),
              activeIcon: Icon(Icons.person),
              label: 'حسابي'),
        ],
      ),
    );
  }
}
