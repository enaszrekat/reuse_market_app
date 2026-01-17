import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'localization/app_localizations.dart';

class LoginPage extends StatefulWidget {
  final Function(Locale) onLangChange;
  const LoginPage({super.key, required this.onLangChange});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final email = TextEditingController();
  final password = TextEditingController();

  void _changeLanguage() {
    final current = Localizations.localeOf(context);
    final newLocale =
        current.languageCode == 'en' ? const Locale('ar') : const Locale('en');
    widget.onLangChange(newLocale);
  }

  void _login() {
    if (email.text.isEmpty || password.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields")),
      );
      return;
    }

    Navigator.pushReplacementNamed(context, "/home");
  }

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context);
    final t = AppLocalizations(locale);

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7F8),

      /// 🔥 الحل هنا: Scroll قبل الـ Container
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 30),
        child: Center(
          child: Container(
            width: MediaQuery.of(context).size.width < 500
                ? double.infinity
                : 460,
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.fromLTRB(40, 36, 40, 36),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(34),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 40,
                  offset: const Offset(0, 25),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset('assets/logo.png', height: 160),
                const SizedBox(height: 40),

                /// TITLE + LANGUAGE
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      t.t("login"),
                      style: GoogleFonts.poppins(
                        fontSize: 34,
                        fontWeight: FontWeight.w700,
                        color: Colors.green,
                      ),
                    ),
                    InkWell(
                      onTap: _changeLanguage,
                      borderRadius: BorderRadius.circular(20),
                      child: Row(
                        children: [
                          const Icon(Icons.language, color: Colors.green),
                          const SizedBox(width: 6),
                          Text(
                            locale.languageCode == 'en'
                                ? "English"
                                : "العربية",
                            style: GoogleFonts.poppins(
                              fontSize: 15,
                              color: Colors.green,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 28),

                _input(Icons.email_outlined, t.t("email"), email),
                const SizedBox(height: 18),
                _input(Icons.lock_outline, t.t("password"), password,
                    isPassword: true),

                const SizedBox(height: 34),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(22),
                      ),
                    ),
                    child: Text(
                      t.t("login"),
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                TextButton(
                  onPressed: () =>
                      Navigator.pushReplacementNamed(context, "/register"),
                  child: Text(
                    t.t("register"),
                    style: GoogleFonts.poppins(
                      color: Colors.green,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),

                const Divider(height: 32),

                TextButton(
                  onPressed: () =>
                      Navigator.pushReplacementNamed(context, "/admin-login"),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.admin_panel_settings,
                          color: Colors.green),
                      const SizedBox(width: 8),
                      Text(
                        "Admin Login",
                        style:
                            GoogleFonts.poppins(color: Colors.green),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _input(
    IconData icon,
    String label,
    TextEditingController controller, {
    bool isPassword = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      style: GoogleFonts.poppins(fontSize: 15),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.green),
        labelText: label,
        filled: true,
        fillColor: const Color(0xFFF2F2F2),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
