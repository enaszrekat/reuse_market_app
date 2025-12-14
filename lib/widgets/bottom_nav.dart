import 'package:flutter/material.dart';
import '../pages/home_page.dart';
import '../pages/profile_page.dart';
import '../pages/my_products_page.dart';
import '../pages/sell_page.dart';
import '../pages/settings_page.dart';

class BottomNav extends StatefulWidget {
  final Function(Locale) onLangChange;
  const BottomNav({super.key, required this.onLangChange});

  @override
  State<BottomNav> createState() => _BottomNavState();
}

class _BottomNavState extends State<BottomNav> {
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final screens = [
      HomePage(onLangChange: widget.onLangChange),
      MyProductsPage(onLangChange: widget.onLangChange),
      SellPage(onLangChange: widget.onLangChange),
      ProfilePage(onLangChange: widget.onLangChange),
      SettingsPage(onLangChange: widget.onLangChange),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),

      body: screens[currentIndex],

      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.4),
          borderRadius: const BorderRadius.only(
            topRight: Radius.circular(28),
            topLeft: Radius.circular(28),
          ),
          border: Border.all(color: Colors.white24, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 14,
              offset: const Offset(0, -4),
            )
          ],
        ),

        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _navItem(Icons.home, "Home", 0),
            _navItem(Icons.grid_view_rounded, "Products", 1),
            _navItem(Icons.add_circle, "Sell", 2, isCenter: true),
            _navItem(Icons.person, "Profile", 3),
            _navItem(Icons.settings, "Settings", 4),
          ],
        ),
      ),
    );
  }

  // -------------------------------------------------------
  Widget _navItem(IconData icon, String label, int index, {bool isCenter = false}) {
    final bool active = index == currentIndex;

    return GestureDetector(
      onTap: () => setState(() => currentIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: isCenter
            ? const EdgeInsets.symmetric(horizontal: 18, vertical: 4)
            : const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: active
            ? BoxDecoration(
                color: const Color(0xFFFFD700).withOpacity(0.20),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: const Color(0xFFFFD700),
                  width: 1.3,
                ),
              )
            : null,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: isCenter ? 32 : 26,
              color: active
                  ? const Color(0xFFFFD700)
                  : Colors.white.withOpacity(0.6),
            ),
            if (!isCenter)
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 300),
                style: TextStyle(
                  color: active
                      ? const Color(0xFFFFD700)
                      : Colors.white.withOpacity(0.6),
                  fontSize: active ? 14 : 12,
                  fontWeight: active ? FontWeight.bold : FontWeight.normal,
                ),
                child: Text(label),
              ),
          ],
        ),
      ),
    );
  }
}
