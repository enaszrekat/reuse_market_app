import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../localization/app_localizations.dart';

class AdminLoginPage extends StatefulWidget {
  final Function(Locale) onLangChange;
  const AdminLoginPage({super.key, required this.onLangChange});

  @override
  State<AdminLoginPage> createState() => _AdminLoginPageState();
}

class _AdminLoginPageState extends State<AdminLoginPage> {
  final email = TextEditingController();
  final password = TextEditingController();
  bool loading = false;

  final String serverUrl =
      "http://10.100.11.28/market_app/admin_login.php";

  Future<bool> loginAdmin(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse(serverUrl),
        body: {"email": email, "password": password},
      );

      final data = json.decode(response.body);
      return data["status"] == "success";
    } catch (_) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context);
    final isRtl = ["ar", "he"].contains(locale.languageCode);

    return Directionality(
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: Colors.white,

        /// 🔙 سهم رجوع مضبوط (يرجع عاللوجين)
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new,
              color: Colors.green,
            ),
            onPressed: () {
              Navigator.pushReplacementNamed(context, "/login");
            },
          ),
        ),

        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 35),
            child: Column(
              children: [
                Text(
                  t.t("admin_login"),
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(height: 35),

                Container(
                  padding: const EdgeInsets.all(26),
                  width: 420,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.admin_panel_settings,
                        size: 60,
                        color: Colors.green,
                      ),
                      const SizedBox(height: 15),

                      Text(
                        t.t("admin_login"),
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(height: 25),

                      TextField(
                        controller: email,
                        decoration: InputDecoration(
                          labelText: t.t("email"),
                        ),
                      ),
                      const SizedBox(height: 15),

                      TextField(
                        controller: password,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: t.t("password"),
                        ),
                      ),
                      const SizedBox(height: 25),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () async {
                            setState(() => loading = true);

                            final ok = await loginAdmin(
                              email.text.trim(),
                              password.text.trim(),
                            );

                            setState(() => loading = false);

                            if (ok) {
                              Navigator.pushReplacementNamed(
                                  context, "/admin-dashboard");
                            } else {
                              _error(locale);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                          ),
                          child: loading
                              ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                              : Text(t.t("admin_login")),
                        ),
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

  void _error(Locale locale) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.redAccent,
        content: Text(
          locale.languageCode == "ar"
              ? "❌ خطأ في البريد الإلكتروني أو كلمة المرور"
              : locale.languageCode == "he"
                  ? "❌ שגיאה במייל או סיסמה"
                  : "❌ Incorrect email or password",
        ),
      ),
    );
  }
}
