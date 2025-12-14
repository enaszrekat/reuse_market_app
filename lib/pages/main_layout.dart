import 'package:flutter/material.dart';

// Drawer الفخم
import '../components/gold_drawer.dart';

// الصفحات
import 'home_page.dart';
import 'my_products_page.dart';
import 'sell_product_page.dart';
import 'profile_page.dart';

class MainLayout extends StatefulWidget {
  final Function(Locale) onLangChange;

  const MainLayout({super.key, required this.onLangChange});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomePage(onLangChange: widget.onLangChange),
      const MyProductsPage(),
      const SellProductPage(),
      const ProfilePage(),
    ];

    return Scaffold(
      extendBody: true,

      drawer: GoldDrawer(
        onNavigate: (index) {
          setState(() => _currentIndex = index);
          Navigator.pop(context);
        },
      ),

      body: pages[_currentIndex],

      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.85),
          border: const Border(
            top: BorderSide(color: Colors.white24, width: 0.5),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() => _currentIndex = index);
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          elevation: 0,

          selectedItemColor: const Color(0xFFFFD700),
          unselectedItemColor: Colors.white54,

          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              label: "Home",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.grid_view_rounded),
              label: "My Products",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.add_circle_outline),
              label: "Add",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              label: "Profile",
            ),
          ],
        ),
      ),
    );
  }
}
