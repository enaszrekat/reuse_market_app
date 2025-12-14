import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  final Function(Locale) onLangChange;
  const SettingsPage({super.key, required this.onLangChange});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage>
    with SingleTickerProviderStateMixin {
  bool notifications = true;
  bool darkMode = true;
  bool goldTheme = true;

  late AnimationController _controller;
  late Animation<double> fadeAnim;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    fadeAnim = Tween<double>(begin: 0, end: 1).animate(_controller);

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // ------------------------------------------------------
  // UI
  // ------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: const Text(
          "Settings",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),

      body: FadeTransition(
        opacity: fadeAnim,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(22),
          child: Column(
            children: [
              // LANGUAGE
              _sectionTitle("Language"),
              const SizedBox(height: 10),
              _languageSelector(),

              const SizedBox(height: 28),

              // THEME
              _sectionTitle("Theme"),
              const SizedBox(height: 10),
              _themeSelector(),

              const SizedBox(height: 28),

              // NOTIFICATIONS
              _sectionTitle("Preferences"),
              const SizedBox(height: 10),
              _switchTile(
                "Notifications",
                notifications,
                (v) => setState(() => notifications = v),
              ),

              const SizedBox(height: 26),

              // LOGOUT BUTTON
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFD700),
                  foregroundColor: Colors.black,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                onPressed: () {
                  Navigator.pushReplacementNamed(context, "/login");
                },
                child: const Text(
                  "Logout",
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ------------------------------------------------------
  Widget _sectionTitle(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xFFFFD700),
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // ------------------------------------------------------
  // LANGUAGE CHIPS
  // ------------------------------------------------------
  Widget _languageSelector() {
    return Column(
      children: [
        _langChip("العربية", const Locale('ar')),
        const SizedBox(height: 10),
        _langChip("עברית", const Locale('he')),
        const SizedBox(height: 10),
        _langChip("English", const Locale('en')),
      ],
    );
  }

  Widget _langChip(String txt, Locale locale) {
    return GestureDetector(
      onTap: () {
        widget.onLangChange(locale);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Language changed to $txt")),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.06),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFFFD700)),
        ),
        child: Row(
          children: [
            const Icon(Icons.language, color: Color(0xFFFFD700)),
            const SizedBox(width: 15),
            Text(
              txt,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            )
          ],
        ),
      ),
    );
  }

  // ------------------------------------------------------
  // THEME SELECTOR
  // ------------------------------------------------------
  Widget _themeSelector() {
    return Column(
      children: [
        _switchTile(
          "Dark Mode",
          darkMode,
          (v) => setState(() => darkMode = v),
        ),
        const SizedBox(height: 14),
        _switchTile(
          "Gold Theme",
          goldTheme,
          (v) => setState(() => goldTheme = v),
        ),
      ],
    );
  }

  // ------------------------------------------------------
  Widget _switchTile(String title, bool value, Function(bool) onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white24),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFFFFD700),
            activeTrackColor: Colors.white24,
            inactiveTrackColor: Colors.white24,
          )
        ],
      ),
    );
  }
}
