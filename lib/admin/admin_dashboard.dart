import 'package:flutter/material.dart';
import '../main.dart';

import 'animated_background.dart';
import 'smart_sidebar.dart';

import 'admin_home.dart';
import 'users_management_page.dart';
import 'products_management_page.dart';
import 'reports_page.dart';

class AdminDashboard extends StatefulWidget {
  final Function(Locale) onLangChange;
  final Locale locale;

  const AdminDashboard({
    super.key,
    required this.onLangChange,
    required this.locale,
  });

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    var t = AppLocalizations(widget.locale);

    // RTL for Arabic & Hebrew
    bool isRtl = ["ar", "he"].contains(widget.locale.languageCode);

    final List<Widget> pages = const [
      AdminHome(),
      UsersManagementPage(),
      ProductsManagementPage(),
      ReportsPage(),
    ];

    return Directionality(
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,

      child: Scaffold(
        body: AnimatedBackground(
          child: Row(
            children: [
              // SIDEBAR LEFT (English)
              if (!isRtl)
                SmartSidebar(
                  isRtl: isRtl,
                  selectedIndex: selectedIndex,
                  onSelect: onSidebarTap,
                ),

              // MAIN CONTENT AREA
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Padding(
                    key: ValueKey(selectedIndex),
                    padding: const EdgeInsets.all(32),
                    child: pages[selectedIndex],
                  ),
                ),
              ),

              // SIDEBAR RIGHT (Arabic/Hebrew)
              if (isRtl)
                SmartSidebar(
                  isRtl: isRtl,
                  selectedIndex: selectedIndex,
                  onSelect: onSidebarTap,
                ),
            ],
          ),
        ),
      ),
    );
  }

  // Handle sidebar selections
  void onSidebarTap(int index) {
    if (index == 99) {
      Navigator.pop(context); // logout
      return;
    }

    setState(() => selectedIndex = index);
  }
}
