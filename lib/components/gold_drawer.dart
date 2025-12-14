import 'package:flutter/material.dart';

class GoldDrawer extends StatelessWidget {
  final Function(int) onNavigate;
  const GoldDrawer({super.key, required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.black,
      child: Stack(
        children: [
          // ✨ خلفية ذهبية متدرجة
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.black,
                  Colors.black.withOpacity(0.95),
                  Colors.black.withOpacity(0.90),
                  const Color(0xFF3A2A14),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          // ✨ طبقة Glass شفافة
          Container(
            color: Colors.white.withOpacity(0.05),
          ),

          // 🌟 المحتوى
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // -----------------------------
                // 🔥 HEADER
                // -----------------------------
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.white.withOpacity(0.15),
                        child: const Icon(Icons.person,
                            color: Colors.amber, size: 34),
                      ),
                      const SizedBox(width: 15),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Welcome",
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 13,
                            ),
                          ),
                          const Text(
                            "User",
                            style: TextStyle(
                              color: Colors.amber,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                // -----------------------------
                // 🔹 Navigation Items
                // -----------------------------
                _drawerItem(
                  icon: Icons.home_outlined,
                  text: "Home",
                  onTap: () => onNavigate(0),
                ),

                _drawerItem(
                  icon: Icons.grid_view_rounded,
                  text: "My Products",
                  onTap: () => onNavigate(1),
                ),

                _drawerItem(
                  icon: Icons.add_circle_outline,
                  text: "Add Product",
                  onTap: () => onNavigate(2),
                ),

                _drawerItem(
                  icon: Icons.person_outline,
                  text: "Profile",
                  onTap: () => onNavigate(3),
                ),

                const Divider(color: Colors.white24, thickness: 0.5),

                _drawerItem(
                  icon: Icons.settings_outlined,
                  text: "Settings",
                  onTap: () {},
                ),

                _drawerItem(
                  icon: Icons.notifications_active_outlined,
                  text: "Notifications",
                  onTap: () {},
                ),

                const Spacer(),

                // -----------------------------
                // 🔥 Logout
                // -----------------------------
                _drawerItem(
                  icon: Icons.logout,
                  text: "Logout",
                  color: Colors.redAccent,
                  onTap: () {
                    Navigator.pushReplacementNamed(context, "/login");
                  },
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------
  // 🔹 drawer item reusable
  // ---------------------------------------------------
  Widget _drawerItem({
    required IconData icon,
    required String text,
    required Function() onTap,
    Color color = Colors.white,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
        child: Row(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(width: 14),
            Text(
              text,
              style: TextStyle(
                color: color,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}