// lib/pages/main_menu_page.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:frontend_app/main.dart';

class MainMenuPage extends StatefulWidget {
  final Function(Locale) onLangChange;

  /// إذا عرفتي اسم المستخدم من الـ login.php
  /// تقدري تبعتيه هون، وإذا مش موجود رح يظهر "Guest".
  final String? userName;

  const MainMenuPage({
    super.key,
    required this.onLangChange,
    this.userName,
  });

  @override
  State<MainMenuPage> createState() => _MainMenuPageState();
}

class _MainMenuPageState extends State<MainMenuPage> {
  int _bottomIndex = 0;

  // للتحكم بالـ gradient animation
  int _gradientIndex = 0;
  late Timer _timer;

  final List<List<Color>> _gradients = [
    [
      const Color(0xFFF5EFE6), // بيج فاتح
      const Color(0xFFE8D9C0), // بيج أغمق شوي
      const Color(0xFFD9C2A3), // بني فاتح
    ],
    [
      const Color(0xFFF9F4EB),
      const Color(0xFFEAD7C2),
      const Color(0xFFC9B09A),
    ],
    [
      const Color(0xFFF5EFE6),
      const Color(0xFFECE0D1),
      const Color(0xFFCFB89A),
    ],
  ];

  @override
  void initState() {
    super.initState();

    // كل 7 ثواني نغيّر ألوان الـ gradient بهدوء
    _timer = Timer.periodic(const Duration(seconds: 7), (_) {
      setState(() {
        _gradientIndex = (_gradientIndex + 1) % _gradients.length;
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context);
    final t = AppLocalizations(locale);
    final isRtl = ["ar", "he"].contains(locale.languageCode);

    final String displayName = widget.userName ?? "Guest";

    return Directionality(
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        drawer: _buildDrawer(displayName),
        backgroundColor: Colors.transparent,

        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(
            "Main Menu",
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          actions: [
            PopupMenuButton<Locale>(
              icon: const Icon(Icons.language, color: Colors.white),
              onSelected: widget.onLangChange,
              itemBuilder: (context) => const [
                PopupMenuItem(value: Locale('ar'), child: Text("🇸🇦 العربية")),
                PopupMenuItem(value: Locale('he'), child: Text("🇮🇱 עברית")),
                PopupMenuItem(value: Locale('en'), child: Text("🇬🇧 English")),
              ],
            ),
          ],
        ),

        // 🔥 الخلفية المتحركة + المحتوى فوقها
        body: Stack(
          children: [
            _AnimatedGradientBackground(
              colors: _gradients[_gradientIndex],
            ),

            SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 👋 عنوان ترحيب
                    Text(
                      locale.languageCode == "ar"
                          ? "مرحباً، $displayName 👋"
                          : locale.languageCode == "he"
                              ? "היי, $displayName 👋"
                              : "Hi, $displayName 👋",
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF5B5140),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      locale.languageCode == "ar"
                          ? "شو حاب/ة تعملي اليوم؟"
                          : locale.languageCode == "he"
                              ? "מה בא לך לעשות היום?"
                              : "What would you like to do today?",
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF7C705E),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // 🧱 الشبكة (Grid)
                    Expanded(
                      child: GridView.count(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 1.2,
                        children: [
                          MainMenuCard(
                            title: "Sell Product",
                            icon: Icons.sell_outlined,
                            color: const Color(0xFF8D6E63),
                            onTap: () {
                              // TODO: روحي لصفحة البيع
                              // Navigator.pushNamed(context, "/sell");
                            },
                          ),
                          MainMenuCard(
                            title: "Trade Product",
                            icon: Icons.sync_alt_rounded,
                            color: const Color(0xFF6D6875),
                            onTap: () {
                              // TODO: صفحة التبديل
                            },
                          ),
                          MainMenuCard(
                            title: "Donate Item",
                            icon: Icons.volunteer_activism_outlined,
                            color: const Color(0xFF7E6D57),
                            onTap: () {
                              // TODO: صفحة التبرع
                            },
                          ),
                          MainMenuCard(
                            title: "My Products",
                            icon: Icons.inventory_2_outlined,
                            color: const Color(0xFF5C6BC0),
                            onTap: () {
                              // TODO: صفحة منتجاتي
                            },
                          ),
                          MainMenuCard(
                            title: "Profile",
                            icon: Icons.person_outline,
                            color: const Color(0xFF00897B),
                            onTap: () {
                              // TODO: صفحة البروفايل
                            },
                          ),
                          MainMenuCard(
                            title: "Notifications",
                            icon: Icons.notifications_outlined,
                            color: const Color(0xFFB26A5A),
                            onTap: () {
                              // TODO: صفحة الإشعارات
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),

        // ⭐ Bottom Navigation Bar
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _bottomIndex,
          onTap: (i) {
            setState(() => _bottomIndex = i);
            // إذا حابة تعملي تنقل حقيقي بين Tabs حطي Navigator هون
          },
          selectedItemColor: const Color(0xFF6B5F46),
          unselectedItemColor: const Color(0xFFB0A18C),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              label: "Home",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.chat_bubble_outline),
              label: "Chats",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings_outlined),
              label: "Settings",
            ),
          ],
        ),
      ),
    );
  }

  // ⭐ Drawer بسيط مع معلومات المستخدم
  Drawer _buildDrawer(String name) {
    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(
                name.isNotEmpty ? name[0].toUpperCase() : "?",
                style: const TextStyle(
                  fontSize: 26,
                  color: Color(0xFF6B5F46),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            accountName: Text(name),
            accountEmail: const Text(""),
            decoration: const BoxDecoration(
              color: Color(0xFF6B5F46),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.person_outline),
            title: const Text("Profile"),
            onTap: () {
              // TODO: افتحي صفحة البروفايل
            },
          ),
          ListTile(
            leading: const Icon(Icons.inventory_2_outlined),
            title: const Text("My Products"),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.notifications_outlined),
            title: const Text("Notifications"),
            onTap: () {},
          ),
          const Spacer(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text("Logout"),
            onTap: () {
              // TODO: ارجعي لصفحة الLogin
              // Navigator.pushReplacementNamed(context, "/login");
            },
          ),
        ],
      ),
    );
  }
}

/// ------------------------------------------------------
/// 🔥 Widget الخلفية المتحركة
/// ------------------------------------------------------
class _AnimatedGradientBackground extends StatelessWidget {
  final List<Color> colors;

  const _AnimatedGradientBackground({required this.colors});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(seconds: 7),
      tween: Tween(begin: 0, end: 1),
      builder: (context, value, child) {
        // بنغيّر الـ alignment شوي عشان يعطي إحساس حركة ناعم
        final alignment1 = Alignment(-1 + value, -1);
        final alignment2 = Alignment(1, 1 - value);

        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: alignment1,
              end: alignment2,
              colors: colors,
            ),
          ),
        );
      },
    );
  }
}

/// ------------------------------------------------------
/// 🧱 كرت في الشبكة مع Hover + Animation
/// ------------------------------------------------------
class MainMenuCard extends StatefulWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const MainMenuCard({
    super.key,
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  State<MainMenuCard> createState() => _MainMenuCardState();
}

class _MainMenuCardState extends State<MainMenuCard> {
  bool _hovered = false;
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) {
          setState(() => _pressed = false);
          widget.onTap();
        },
        onTapCancel: () => setState(() => _pressed = false),
        child: AnimatedScale(
          duration: const Duration(milliseconds: 130),
          scale: _pressed
              ? 0.97
              : _hovered
                  ? 1.03
                  : 1.0,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.92),
              borderRadius: BorderRadius.circular(22),
              boxShadow: _hovered
                  ? [
                      BoxShadow(
                        color: widget.color.withOpacity(0.28),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                    ]
                  : [
                      BoxShadow(
                        color: Colors.brown.withOpacity(0.10),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: widget.color.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Icon(
                      widget.icon,
                      color: widget.color,
                      size: 26,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  widget.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4A3F34),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "Tap to continue",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
