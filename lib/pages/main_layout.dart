import 'package:flutter/material.dart';

// Pages
import 'products_page.dart';
import 'inbox_page.dart';
import 'my_products_page.dart';
import 'profile_page.dart';
import 'add_product_sheet.dart';

class MainLayout extends StatefulWidget {
  final Function(Locale) onLangChange;
  const MainLayout({super.key, required this.onLangChange});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    ProductsPage(),   // 🏠
    InboxPage(),      // 📦
    MyProductsPage(), // 📦 My Products
    ProfilePage(),    // 👤
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0E1412),

      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Stack(
            children: [
              Positioned.fill(
                child: IndexedStack(
                  index: _currentIndex,
                  children: _pages,
                ),
              ),

              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: _buildBottomBar(),
              ),
            ],
          ),
        ),
      ),

      // ➕ Add Product
      floatingActionButtonLocation:
          FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF3DDC97),
        foregroundColor: Colors.black,
        elevation: 8,
        onPressed: _openAddProduct,
        child: const Icon(Icons.add, size: 28),
      ),
    );
  }

  // ⬇️ Bottom Navigation (محسّن)
  Widget _buildBottomBar() {
    return BottomAppBar(
      color: const Color(0xFF151E1B),
      shape: const CircularNotchedRectangle(),
      notchMargin: 10,
      elevation: 8,
      child: SizedBox(
        height: 74,
        child: Row(
          children: [
            _navItem(
              icon: Icons.home_rounded,
              label: "Products",
              index: 0,
            ),

            _navItem(
              icon: Icons.chat_bubble_rounded,
              label: "Inbox",
              index: 1,
            ),

            const SizedBox(width: 56), // مساحة زر +

            _navItem(
              icon: Icons.inventory_2_rounded,
              label: "My Products",
              index: 2,
            ),

            _navItem(
              icon: Icons.person_rounded,
              label: "Profile",
              index: 3,
            ),
          ],
        ),
      ),
    );
  }

  // 🔘 Nav Item (Indicator احترافي)
  Widget _navItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    final bool isActive = _currentIndex == index;

    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _currentIndex = index),
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 24,
              color: isActive
                  ? const Color(0xFF3DDC97)
                  : Colors.white38,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w600,
                color: isActive
                    ? const Color(0xFF3DDC97)
                    : Colors.white38,
              ),
            ),

            // 🟢 Indicator
            const SizedBox(height: 4),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: isActive ? 18 : 0,
              height: 3,
              decoration: BoxDecoration(
                color: const Color(0xFF3DDC97),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🧾 Add Product Sheet
  void _openAddProduct() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const AddProductSheet(),
    );
  }
}
