import 'dart:ui';
import 'package:flutter/material.dart';
import '../main.dart';

class SmartSidebar extends StatefulWidget {
  final bool isRtl;
  final Function(int) onSelect;
  final int selectedIndex;

  const SmartSidebar({
    super.key,
    required this.isRtl,
    required this.onSelect,
    required this.selectedIndex,
  });

  @override
  State<SmartSidebar> createState() => _SmartSidebarState();
}

class _SmartSidebarState extends State<SmartSidebar> {
  bool expanded = false;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations(Localizations.localeOf(context));

    return MouseRegion(
      onEnter: (_) => setState(() => expanded = true),
      onExit: (_) => setState(() => expanded = false),

      child: AnimatedContainer(
        duration: const Duration(milliseconds: 260),
        width: expanded ? 240 : 78,        // ← حجم آمن بدون Overflow
        curve: Curves.easeOut,
        margin: const EdgeInsets.all(12),

        child: ClipRRect(
          borderRadius: BorderRadius.circular(26),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),

            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.13),
                borderRadius: BorderRadius.circular(26),
                border: Border.all(color: Colors.white.withOpacity(0.18)),
              ),

              padding: const EdgeInsets.symmetric(vertical: 22),

              child: Column(
                children: [
                  _item(Icons.dashboard_rounded, t.t("dashboard"), 0),
                  _item(Icons.people_alt_rounded, t.t("users"), 1),
                  _item(Icons.inventory_2_rounded, t.t("products"), 2),
                  _item(Icons.bar_chart_rounded, t.t("reports"), 3),

                  const Spacer(),

                  _item(Icons.logout_rounded, t.t("logout"), 99),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _item(IconData icon, String label, int index) {
    bool active = widget.selectedIndex == index;

    return GestureDetector(
      onTap: () => widget.onSelect(index),

      child: AnimatedContainer(
        duration: const Duration(milliseconds: 230),
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),

        decoration: BoxDecoration(
          color: active ? Colors.white.withOpacity(0.30) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),

        child: Row(
          textDirection: widget.isRtl ? TextDirection.rtl : TextDirection.ltr,
          children: [
            Icon(
              icon,
              color: Colors.white,
              size: 24,
            ),

            if (expanded) ...[
              const SizedBox(width: 12),

              Expanded(
                child: AnimatedOpacity(
                  opacity: expanded ? 1 : 0,
                  duration: const Duration(milliseconds: 180),
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.fade,
                    softWrap: false,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
