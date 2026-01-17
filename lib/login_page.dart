import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'localization/app_localizations.dart';
import 'config.dart';
import 'theme/app_theme.dart';
import 'components/premium_logo.dart';

class LoginPage extends StatefulWidget {
  final Function(Locale) onLangChange;
  const LoginPage({super.key, required this.onLangChange});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController email = TextEditingController();
  final TextEditingController password = TextEditingController();

  bool loading = false;


  void _showLanguageSelector() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceDark,
        title: const Text("Select Language", style: AppTheme.textStyleTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.language, color: AppTheme.primaryGreen),
              title: const Text("English", style: AppTheme.textStyleBody),
              onTap: () {
                widget.onLangChange(const Locale('en'));
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.language, color: AppTheme.primaryGreen),
              title: const Text("العربية", style: AppTheme.textStyleBody),
              onTap: () {
                widget.onLangChange(const Locale('ar'));
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.language, color: AppTheme.primaryGreen),
              title: const Text("עברית", style: AppTheme.textStyleBody),
              onTap: () {
                widget.onLangChange(const Locale('he'));
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  // ============================
  // LOGIN (الحل الحقيقي)
  // ============================
  Future<void> _login() async {
    if (email.text.isEmpty || password.text.isEmpty) {
      final locale = Localizations.localeOf(context);
      final t = AppLocalizations(locale);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Please fill in all fields", style: AppTheme.textStyleBody),
                    backgroundColor: AppTheme.errorRed,
                  ),
                );
      return;
    }

    setState(() => loading = true);

    try {
      final base = AppConfig.baseUrl.endsWith('/') 
          ? AppConfig.baseUrl 
          : '${AppConfig.baseUrl}/';
      final url = "${base}login.php";
      
      final response = await http.post(
        Uri.parse(url),
        body: {
          "email": email.text.trim(),
          "password": password.text.trim(),
        },
      );

      final data = json.decode(response.body);

      if (data["status"] == "success") {
        final prefs = await SharedPreferences.getInstance();

        // 🔥 أهم سطر بالمشروع كله
        await prefs.setInt("user_id", data["user"]["id"]);
        
        // ✅ Force English locale after successful login
        widget.onLangChange(const Locale('en'));

        if (!mounted) return;
        Navigator.pushReplacementNamed(context, "/home");
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data["message"] ?? "Login failed", style: AppTheme.textStyleBody),
            backgroundColor: AppTheme.errorRed,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Connection error. Please try again.", style: AppTheme.textStyleBody),
          backgroundColor: AppTheme.errorRed,
        ),
      );
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  // ============================
  // UI
  // ============================
  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context);
    final t = AppLocalizations(locale);

    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.backgroundDark,
              AppTheme.backgroundDark.withOpacity(0.95),
              AppTheme.surfaceDark,
            ],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 30),
          child: Center(
            child: Container(
              width: MediaQuery.of(context).size.width < 500
                  ? double.infinity
                  : 460,
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: AppTheme.paddingPage,
              decoration: BoxDecoration(
                color: AppTheme.surfaceDark,
                borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                border: Border.all(
                  color: AppTheme.primaryGreen.withOpacity(0.3),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryGreen.withOpacity(0.2),
                    blurRadius: 40,
                    offset: const Offset(0, 25),
                  ),
                ],
              ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Premium Logo - Large and Centered
                Center(
                  child: PremiumLogoWithIcon(
                    height: 220,
                    showSubtitle: false,
                  ),
                ),
                const SizedBox(height: 40),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      t.t("login"),
                      style: AppTheme.textStyleHeadline.copyWith(
                        fontSize: 34,
                        color: AppTheme.primaryGreen,
                      ),
                    ),
                    InkWell(
                      onTap: _showLanguageSelector,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryGreen.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                          border: Border.all(color: AppTheme.primaryGreen.withOpacity(0.3)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.language, color: AppTheme.primaryGreen, size: 20),
                            const SizedBox(width: 6),
                            Text(
                              locale.languageCode == 'en'
                                  ? "English"
                                  : locale.languageCode == 'ar'
                                      ? "العربية"
                                      : "עברית",
                              style: AppTheme.textStyleBodySmall.copyWith(
                                color: AppTheme.primaryGreen,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 28),

                _input(Icons.email, t.t("email"), email),
                const SizedBox(height: 18),
                _input(Icons.lock, t.t("password"), password,
                    isPassword: true),

                const SizedBox(height: 34),

                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: loading ? null : _login,
                    style: AppTheme.primaryButtonStyle,
                    child: loading
                        ? const CircularProgressIndicator(color: Colors.black)
                        : Text(
                            t.t("login"),
                            style: AppTheme.textStyleBody.copyWith(
                              fontSize: 18,
                              fontWeight: AppTheme.fontWeightBold,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: AppTheme.spacingLarge),

                TextButton(
                  onPressed: () =>
                      Navigator.pushReplacementNamed(context, "/register"),
                  child: Text(
                    t.t("register"),
                    style: AppTheme.textStyleBody.copyWith(
                      color: AppTheme.primaryGreen,
                    ),
                  ),
                ),

                const SizedBox(height: AppTheme.spacingMedium),
                Divider(color: AppTheme.primaryGreen.withOpacity(0.3)),
                const SizedBox(height: AppTheme.spacingMedium),

                OutlinedButton.icon(
                  onPressed: () =>
                      Navigator.pushReplacementNamed(context, "/admin-login"),
                  style: AppTheme.secondaryButtonStyle,
                  icon: const Icon(Icons.admin_panel_settings, size: 20),
                  label: const Text("Admin Login"),
                ),
              ],
            ),
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
      style: AppTheme.textStyleBody,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: AppTheme.primaryGreen),
        labelText: label,
        labelStyle: AppTheme.textStyleBodySecondary,
        filled: true,
        fillColor: AppTheme.surfaceSecondary,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          borderSide: BorderSide(color: AppTheme.primaryGreen.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          borderSide: const BorderSide(color: AppTheme.primaryGreen, width: 2),
        ),
      ),
    );
  }
}
