import 'dart:ui';
import 'package:flutter/material.dart';
import '../../main.dart';

class TopNavbar extends StatelessWidget {
  final Function(Locale) onLangChange;
  final String title;

  const TopNavbar({
    super.key,
    required this.onLangChange,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context);
    final t = AppLocalizations(locale);

    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.18),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: Colors.white.withOpacity(0.25)),
          ),

          child: Row(
            children: [
              // ---- Title ----
              Text(
                title,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),

              const Spacer(),

              // ---- Search Bar ----
              Container(
                width: 260,
                height: 40,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.search, color: Colors.white70),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: t.t("search") ?? "Search...",
                          hintStyle:
                              TextStyle(color: Colors.white.withOpacity(0.55)),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 20),

              // ---- Notifications ----
              _iconButton(Icons.notifications_rounded),

              const SizedBox(width: 16),

              // ---- Language Menu ----
              PopupMenuButton<Locale>(
                icon: const Icon(Icons.language, color: Colors.white, size: 28),
                color: Colors.white,
                onSelected: onLangChange,
                itemBuilder: (context) => [
                  const PopupMenuItem(
                      value: Locale('ar'), child: Text("🇸🇦 العربية")),
                  const PopupMenuItem(
                      value: Locale('he'), child: Text("🇮🇱 עברית")),
                  const PopupMenuItem(
                      value: Locale('en'), child: Text("🇬🇧 English")),
                ],
              ),

              const SizedBox(width: 18),

              // ---- Profile Avatar ----
              CircleAvatar(
                radius: 22,
                backgroundColor: Colors.white.withOpacity(0.4),
                child: const Icon(Icons.person, color: Colors.white, size: 28),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _iconButton(IconData icon) {
    return Container(
      height: 42,
      width: 42,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.18),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Icon(icon, color: Colors.white, size: 24),
    );
  }
}